require 'readline'

module JimmyJukebox

  # make system call and get pid so you can terminate process
  def system_yield_pid(*cmd)
    pid = fork do             # creates and runs block in subprocess (which will terminate with status 0), capture subprocess pid
      exec(*cmd)              # replaces current process with system call
      exit! 127               # exit process and return exit status 127
    end
    yield pid if block_given? # call block, passing in the subprocess pid
    Process.waitpid(pid)      # Waits for a child process to exit, returns its process id, and sets $? to a Process::Status object
    $?                        # return Process::Status object with instance methods .stopped?, .exited?, .exitstatus; see: http://www.ruby-doc.org/core/classes/Process/Status.html
  end

  class Jukebox

    attr_reader :loop, :current_song_paused, :playing_pid

    DEFAULT_MP3_DIR = "~/Music"
    DEFAULT_PLAYLIST_DIR = "~/.jimmy_jukebox"

    def initialize
      test_existence_of_mpg123_and_ogg123
      generate_directories_list
      generate_song_list
    end

    def play_loop
      @loop = true
      while @loop do
        play
      end
    end

    def play
      begin
        play_random_song
      rescue SystemExit, Interrupt => e
        terminate_current_song
        puts "\nMusic terminated by user"
        exit
      end
    end

    def quit
      stop_looping
      terminate_current_song
    end

    def skip_song
      terminate_current_song
    end

    def pause_current_song
      @current_song_paused = true
      system("kill -s STOP #{@playing_pid}") if @playing_pid
    end

    def unpause_current_song
      @current_song_paused = false
      system("kill -s CONT #{@playing_pid}") if @playing_pid
    end

    private

    def stop_looping
      @loop = false
    end

    def test_existence_of_mpg123_and_ogg123
      require 'rbconfig'
      if ogg123_exists? && mpg123_exists?
        @ogg123_installed = true
        @mpg123_installed = true
        return
      elsif ogg123_exists? && !mpg123_exists?
        puts "*** YOU CANNOT PLAY MP3S UNTIL YOU INSTALL MPG123 ***"
        @ogg123_installed = true
        @mpg123_installed = false
        return
      elsif mpg123_exists? && !ogg123_exists?
        puts "*** YOU CANNOT PLAY OGG FILES UNTIL YOU INSTALL OGG123 ***"
        @mpg123_installed = true
        @ogg123_installed = false
        return
      elsif ['mac','darwin'].include?(RbConfig::CONFIG['host_os'])
        @afplay_installed = true
      else
        error_msg = "*** YOU MUST INSTALL ogg123 AND/OR mpg123 BEFORE USING JIMMYJUKEBOX ***"
        puts error_msg
        exit
      end
    end

    def ogg123_exists?
      `which ogg123`.match(/.*\/ogg123$/) ? true : false
    end

    def mpg123_exists?
      `which mpg123`.match(/.*\/mpg123$/) ? true : false
    end

    def set_music_directories_from_file
      if File.exists?(File.expand_path(ARGV[0]))
        @music_directories_file = File.expand_path(ARGV[0])
      elsif File.exists?(File.expand_path(DEFAULT_PLAYLIST_DIR + '/' + ARGV[0]))
        @music_directories_file = File.expand_path(DEFAULT_PLAYLIST_DIR + '/' + ARGV[0])
      end
      load_top_level_directories_from_file
    end

    def play_random_song
      terminate_current_song
      raise "JimmyJukebox has no songs to play!" if @songs.length == 0
      music_file = @songs[rand(@songs.length)]
      play_file(music_file)
    end

    def terminate_current_song
      if @playing_pid
        Process.kill("SIGHUP",@playing_pid)
        @playing_pid = nil
      end
    end

    def generate_directories_list
      @music_directories = []
      # ARGV[0] can be "jazz.txt" (a file holding directory names), "~/Music/JAZZ" (a directory path) or nil
      if ARGV.empty?
        @music_directories << File.expand_path(DEFAULT_MP3_DIR)
      elsif is_a_txt_file?(ARGV[0])
        set_music_directories_from_file
      elsif is_a_directory?(ARGV[0])
        @music_directories << File.expand_path(ARGV[0])
      else
        @music_directories << File.expand_path(DEFAULT_MP3_DIR)
      end
      add_all_subdirectories
    end

    def is_a_txt_file?(whatever)
      return false unless whatever
      whatever.match(/.*\.txt/) ? true : false
    end

    def is_a_directory?(whatever)
      return false unless whatever
      File.directory?(File.expand_path(whatever)) ? true : false
    end

    def load_top_level_directories_from_file
      File.open(@music_directories_file, "r") do |inf|
        while (line = inf.gets)
          line.strip!
          @music_directories << File.expand_path(line)
        end
      end
    end

    def add_all_subdirectories
      new_dirs = []
      @music_directories.each do |dir|
        Dir.chdir(dir)
        new_dirs = new_dirs + Dir.glob("**/").map { |dir_name| File.expand_path(dir_name) }
      end
      @music_directories = @music_directories + new_dirs
    end

    def generate_song_list
      @songs = []
      @music_directories.each do |music_dir|
        files = Dir.entries(File.expand_path(music_dir))
        files.delete_if { |f| !f.match(/.*\.mp3/i) && !f.match(/.*\.ogg/i) }
        files.map! { |f| File.expand_path(music_dir) + '/' + f }
        @songs = @songs + files
      end
      raise "JimmyJukebox could not find any songs" unless @songs.length > 0
      #songs = ["~/Music/Artie_Shaw/Georgia On My Mind 1941.mp3",
      #         "~/Music/Jelly_Roll_Morton/High Society 1939.mp3"]
    end

    def play_file(music_file)
      # TODO: refactor the duplicate code below into a method
      if music_file =~ /\.mp3$|\.ogg$/ && @afplay_installed
        process_status = system_yield_pid("afplay", File.expand_path(music_file)) do |pid|
          @playing_pid = pid 
        end
      elsif music_file =~ /\.mp3$/i && @mpg123_installed
        puts "Press Ctrl-C to stop the music and exit this program"
        process_status = system_yield_pid("mpg123", File.expand_path(music_file)) do |pid|
          @playing_pid = pid 
        end
      elsif music_file =~ /\.ogg$/i && @ogg123_installed
        puts "Press Ctrl-C to stop the music and exit this program"
        process_status = system_yield_pid("ogg123", File.expand_path(music_file)) do |pid|
          @playing_pid = pid 
        end
      else
        raise "Attempted to play a file format this program cannot play"
      end
      process_status.exitstatus.to_i == 0 ? (@playing_pid = nil) : (raise "Experienced a problem playing a song")
    end

  end

end
