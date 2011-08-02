require 'readline'

module JimmyJukebox

  # make system call and get pid so you can terminate process
  def system_yield_pid(*cmd)
    pid = fork do
      exec(*cmd)
      exit! 127
    end
    yield pid if block_given?
    Process.waitpid(pid)
    $?
  end

  class Jukebox

    attr_reader :current_song_paused, :playing_pid

    def initialize
      generate_directories_list
      generate_song_list
    end

    def play_loop
      while true do
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

    def set_music_directories_file
      if File.exists?(File.expand_path(ARGV[0]))
        @music_directories_file = File.expand_path(ARGV[0])
      elsif File.exists?(File.expand_path("~/.jimmy_jukebox/" + ARGV[0]))
        @music_directories_file = File.expand_path("~/.jimmy_jukebox/" + ARGV[0])
      end
      load_top_level_directories_from_file
    end

    def play_random_song
      terminate_current_song
      puts "Press Ctrl-C to stop the music and exit this program"
      mp3_file = @songs[rand(@songs.length)]
      play_file(mp3_file)
    end

    def terminate_current_song
      Process.kill("SIGHUP",@playing_pid) if @playing_pid
    end

    def generate_directories_list
      @mp3_directories = []
      # ARGV[0] can be "jazz.txt" (a file holding directory names), "~/Music/JAZZ" (a directory path) or nil
      if argv0_is_a_txt_file?
        set_music_directories_file
      elsif argv0_is_a_directory?
        @mp3_directories << File.expand_path(ARGV[0])
      else
        @mp3_directories << File.expand_path("~/Music")
      end
      add_all_subdirectories
    end

    def argv0_is_a_txt_file?
      return false unless ARGV[0]
      ARGV[0].match(/.*\.txt/) ? true : false
    end

    def argv0_is_a_directory?
      return false unless ARGV[0]
      File.directory?(File.expand_path(ARGV[0])) ? true : false
    end

    def load_top_level_directories_from_file
      File.open(@music_directories_file, "r") do |inf|
        while (line = inf.gets)
          line.strip!
          @mp3_directories << File.expand_path(line)
        end
      end
    end

    def add_all_subdirectories
      new_dirs = []
      @mp3_directories.each do |dir|
        Dir.chdir(dir)
        new_dirs += Dir.glob("**/")
      end
      @mp3_directories += new_dirs
    end

    def generate_song_list
      @songs = []
      @mp3_directories.each do |mp3_dir|
        files = Dir.entries(File.expand_path(mp3_dir))
        files.delete_if { |f| !f.match(/.*\.mp3/) && !f.match(/.*\.ogg/) }
        files.map! { |f| File.expand_path(mp3_dir) + '/' + f }
        @songs = @songs + files
      end
      #songs = ["~/Music/Artie_Shaw/Georgia On My Mind 1941.mp3",
      #         "~/Music/Jelly_Roll_Morton/High Society 1939.mp3"]
    end

    def play_file(mp3_file)
      if mp3_file.match(/\.mp3$/)
        system_yield_pid("mpg123", File.expand_path(mp3_file)) do |pid|
          @playing_pid = pid 
        end
      elsif mp3_file.match(/\.ogg$/)
        system_yield_pid("ogg123", File.expand_path(mp3_file)) do |pid|
          @playing_pid = pid 
        end
      end
      @playing_pid = nil
    end

  end

end
