begin
  require 'rubygems'
rescue LoadError
  raise "*** You must install 'rubygems' and then install the 'spoon' gem to use JimmyJukebox on JRuby ***"
end

#require 'shellwords'

if (defined?(JRUBY_VERSION) || RUBY_PLATFORM == 'java')
  begin
    Gem::Specification.find_by_name('spoon') # Gem.available?('spoon')
    gem 'spoon'
  rescue LoadError
    puts "*** You must install the 'spoon' gem to use JimmyJukebox on JRuby ***"
    exit
  end
end

module JimmyJukebox

  # make system call and get pid so you can terminate process
  def system_yield_pid(*cmd)
    # would like to use Process.respond_to?(:fork) but JRuby mistakenly returns true
    if (defined?(JRUBY_VERSION) || RUBY_PLATFORM == 'java')
      pid = Spoon.spawnp(*cmd)
    else
      begin
        pid = fork do             # creates and runs block in subprocess (which will terminate with status 0), capture subprocess pid
          exec(*cmd)              # replaces current process with system call
          exit! 127               # exit process and return exit status 127; should never be reached
        end
      rescue NotImplementedError
        raise "*** fork()...exec() not supported ***"
      end
    end
    yield pid if block_given? # call block, passing in the subprocess pid
    Process.waitpid(pid)      # Waits for a child process to exit, returns its process id, and sets $? to a Process::Status object
    $?                        # return Process::Status object with instance methods .stopped?, .exited?, .exitstatus; see: http://www.ruby-doc.org/core/classes/Process/Status.html
  end

  class Jukebox

    require 'jimmy_jukebox/user_config'

    attr_reader :loop, :current_song_paused, :playing_pid, :music_player

    def initialize
      @user_config = UserConfig.new
    end

    def play_loop
      @loop = true
      while @loop do
        play
      end
    end

    def play
      begin
        play_random_song(@user_config.songs)
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
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      # system("kill -s STOP #{@playing_pid}") if @playing_pid
      `kill -s STOP #{@playing_pid}` if @playing_pid
    end

    def unpause_current_song
      @current_song_paused = false
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      #system("kill -s CONT #{@playing_pid}") if @playing_pid
      `kill -s CONT #{@playing_pid}` if @playing_pid
    end

    private

    def stop_looping
      @loop = false
    end

    def play_random_song(songs)
      terminate_current_song
      raise "JimmyJukebox has no songs to play!" if songs.length == 0
      music_file = songs[rand(songs.length)]
      play_file(music_file)
    end

    def terminate_current_song
      if @playing_pid
        @current_song_paused = false
        #`killall #{@music_player}`
        @music_player = nil
        # killing processes seems problematic in JRuby
        # I've tried several approaches, and nothing seems reliable
        Process.kill("SIGKILL",@playing_pid)
        #Process.kill("SIGTERM",@playing_pid)
        #`kill #{@playing_pid}` if @playing_pid
        @playing_pid = nil
      end
    end

    def play_file(music_file)
      # TODO: refactor the duplicate code below into a method
      if music_file =~ /\.mp3$/i && @user_config.mp3_player
        process_status = play_file_with(music_file, @user_config.mp3_player)
      elsif music_file =~ /\.ogg$/i && @user_config.ogg_player
        process_status = play_file_with(music_file, @user_config.ogg_player)
      else
        raise "Attempted to play a file format this program cannot play"
      end
      process_status.exitstatus.to_i == 0 ? (@playing_pid = nil) : (raise "Experienced a problem playing a song")
    end

    def play_file_with(music_file,player)
      puts "Press Ctrl-C to stop the music and exit this program"
      puts "Now playing '#{music_file}'"
      @music_player = player
      #`#{player} #{File.expand_path(music_file).shellescape}`
      #system_yield_pid(player, File.expand_path(Shellwords.shellescape(music_file))) do |pid|
      system_yield_pid(player, File.expand_path(music_file)) do |pid|
        @playing_pid = pid 
      end
    end

  end

end
