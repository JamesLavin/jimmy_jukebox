module JimmyJukebox

  class Song

    attr_reader :paused, :music_file
    attr_accessor :player, :playing_pid

    def initialize(music_file)
      set_music_file(music_file)
      @paused = false
      @playing_pid = nil
    end

    def set_music_file(music_file)
      if music_file =~ /\.mp3$/i || music_file =~ /\.ogg$/i
        @music_file = music_file
      else
        raise "You can create a song only with an .mp3 or .ogg file"
      end
    end

    def pause
      @paused = true
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      # system("kill -s STOP #{@playing_pid}") if @playing_pid
      `kill -s STOP #{@playing_pid}` if @playing_pid
    end

    def unpause
      @paused = false
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      #system("kill -s CONT #{@playing_pid}") if @playing_pid
      `kill -s CONT #{@playing_pid}` if @playing_pid
    end

    def terminate
      @paused = false
      #`killall #{@player}`
      @player = nil
      # killing processes seems problematic in JRuby
      # I've tried several approaches, and nothing seems reliable
      #Process.kill("SIGKILL",@playing_pid) if @playing_pid
      #Process.kill("SIGTERM",@playing_pid) if @playing_pid
      `kill #{@playing_pid}` if @playing_pid
      @playing_pid = nil
    end

    def set_player(user_config)
      if @music_file =~ /\.mp3$/i
        @player = user_config.mp3_player
      elsif @music_file =~ /\.ogg$/i
        @player = user_config.ogg_player
      end
      raise "Attempted to play a file format this program cannot play" unless @player
    end

    def play(user_config)
      set_player(user_config)
      process_status = play_with_player
      process_status.exitstatus.to_i == 0 ? (@playing_pid = nil) : (raise "Experienced a problem playing a song")
    end

    def play_with_player
      puts "Press Ctrl-C to stop the music and exit this program"
      puts "Now playing '#{@music_file}'"
      command = @player
      arg = File.expand_path(@music_file)
      system_yield_pid(command,arg) do |pid|
        @playing_pid = pid 
      end
    end

  end

  # make system call and get pid so you can terminate process
  def system_yield_pid(command,arg)
    # would like to use Process.respond_to?(:fork) but JRuby mistakenly returns true
    if (defined?(JRUBY_VERSION) || RUBY_PLATFORM == 'java')
      pid = Spoon.spawnp(command,arg)
      Process.waitpid(pid)      # Waits for a child process to exit, returns its process id, and sets $? to a Process::Status object
    else
      begin
        pid = POSIX::Spawn::spawn(command + ' ' + arg)
        stat = Process::waitpid(pid)
        #pid = fork do             # creates and runs block in subprocess (which will terminate with status 0), capture subprocess pid
        #  exec(command)           # replaces current process with system call
        #  exit! 127               # exit process and return exit status 127; should never be reached
        #end
      rescue NotImplementedError
        raise "*** fork()...exec() not supported ***"
      end
    end
    yield pid if block_given? # call block, passing in the subprocess pid
    #if pid
    #  puts "pid: #{pid}"
    #  puts "current_song: #{Jukebox.current_song.inspect}"
    #else
    #  puts "No process id (pid)!"
    #  raise "@current_song: #{Jukebox.current_song.inspect}"
    #end
    $?                        # return Process::Status object with instance methods .stopped?, .exited?, .exitstatus; see: http://www.ruby-doc.org/core/classes/Process/Status.html
  end

end
