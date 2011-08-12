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

    attr_reader :loop, :current_song_paused, :playing_pid, :mp3_player, :ogg_player

    DEFAULT_MP3_DIR = "~/Music"
    DEFAULT_PLAYLIST_DIR = "~/.jimmy_jukebox"

    def initialize
      set_music_players
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

    def set_music_players
      set_ogg_player
      set_mp3_player
      no_player_configured if !@ogg_player && !@mp3_player
      warn_about_partial_functionality if !@ogg_player || !@mp3_player
    end

    def no_player_configured
      puts "*** YOU CANNOT PLAY MP3S OR OGG FILES -- YOU MIGHT WANT TO INSTALL ogg123 AND mpg123/mpg321 BEFORE USING JIMMYJUKEBOX ***"
      exit
    end

    def warn_about_partial_functionality
      if @ogg_player && !@mp3_player
        puts "*** YOU CANNOT PLAY MP3S -- YOU MIGHT WANT TO INSTALL MPG123 OR MPG321 ***"
      elsif @mp3_player && !@ogg_player
        puts "*** YOU CANNOT PLAY OGG FILES -- YOU MIGHT WANT TO INSTALL OGG123 ***"
      end
    end

    def set_ogg_player
      if ogg123_exists?
        @ogg_player = "ogg123"
        return
      elsif music123_exists?
        @ogg_player = "music123"
        return
      elsif afplay_exists?
        @ogg_player = "afplay"
        return
      elsif mplayer_exists?
        @ogg_player = "mplayer -nolirc -noconfig all"
      #elsif RUBY_PLATFORM.downcase.include?('mac') || RUBY_PLATFORM.downcase.include?('darwin')
      #  @ogg_player = "afplay"
      #  return
      #elsif (require 'rbconfig') && ['mac','darwin'].include?(RbConfig::CONFIG['host_os'])
      #  @ogg_player = "afplay"
      end
    end

    def set_mp3_player
      if mpg123_exists?
        @mp3_player = "mpg123"
        return
      elsif mpg321_exists?
        @mp3_player = "mpg321"
        return
      elsif music123_exists?
        @mp3_player = "music123"
        return
      elsif afplay_exists?
        @mp3_player = "afplay"
        return
      elsif mplayer_exists?
        @mp3_player = "mplayer -nolirc -noconfig all"
      #elsif RUBY_PLATFORM.downcase.include?('mac') || RUBY_PLATFORM.downcase.include?('darwin')
      #  @mp3_player = "afplay"
      #  return
      #elsif (require 'rbconfig') && ['mac','darwin'].include?(RbConfig::CONFIG['host_os'])
      #  @mp3_player = "afplay"
      end
    end

    def ogg123_exists?
      `which ogg123`.match(/.*\/ogg123$/) ? true : false
    end

    def mpg123_exists?
      `which mpg123`.match(/.*\/mpg123$/) ? true : false
    end

    def music123_exists?
      `which music123`.match(/.*\/music123$/) ? true : false
    end

    def mpg321_exists?
      `which mpg321`.match(/.*\/mpg321$/) ? true : false
    end

    def afplay_exists?
      `which afplay`.match(/.*\/afplay$/) ? true : false
    end

    def mplayer_exists?
      `which mplayer`.match(/.*\/mplayer$/) ? true : false
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
      if music_file =~ /\.mp3$/i && @mp3_player
        puts "Press Ctrl-C to stop the music and exit this program"
        process_status = system_yield_pid(@mp3_player, File.expand_path(music_file)) do |pid|
          @playing_pid = pid 
        end
      elsif music_file =~ /\.ogg$/i && @ogg_player
        puts "Press Ctrl-C to stop the music and exit this program"
        process_status = system_yield_pid(@ogg_player, File.expand_path(music_file)) do |pid|
          @playing_pid = pid 
        end
      else
        raise "Attempted to play a file format this program cannot play"
      end
      process_status.exitstatus.to_i == 0 ? (@playing_pid = nil) : (raise "Experienced a problem playing a song")
    end

  end

end
