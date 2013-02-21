module JimmyJukebox

  class Song

    class InvalidSongFormatException < Exception; end
    class NoPlayingPidException < Exception; end
    class UnsupportedSongFormatException < Exception; end
    class CannotSpawnProcessException < Exception; end
    class SongTerminatedBadlyException < Exception; end

    attr_reader   :music_file
    attr_writer   :paused
    attr_accessor :player, :playing_pid

    def initialize(in_music_file)
      set_music_file(in_music_file)
      self.paused = false
      self.playing_pid = nil
    end

    def paused?
      @paused
    end

    def set_music_file(in_music_file)
      if in_music_file =~ /\.mp3$/i || in_music_file =~ /\.ogg$/i
        @music_file = in_music_file
      else
        raise InvalidSongFormatException, "JimmyJukebox plays only .mp3/.ogg files. #{in_music_file} is not valid"
      end
    end

    def pause
      self.paused = true
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      # system("kill -s STOP #{playing_pid}") if playing_pid
      if playing_pid
        `kill -s STOP #{playing_pid}`
      else
        raise NoPlayingPidException, "*** Can't pause song because can't find playing_pid #{playing_pid} ***"
      end
    end

    def unpause
      self.paused = false
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      #system("kill -s CONT #{playing_pid}") if playing_pid
      if playing_pid
        `kill -s CONT #{playing_pid}`
      else
        raise NoPlayingPidException, "*** Can't unpause song because can't find playing_pid #{playing_pid} ***"
      end
    end

    def terminate
      self.paused = false
      #`killall #{player}`
      self.player = nil
      # killing processes seems problematic in JRuby
      # I've tried several approaches, and nothing seems reliable
      #Process.kill("SIGKILL",playing_pid) if playing_pid
      #Process.kill("SIGTERM",playing_pid) if playing_pid
      if playing_pid
        `kill #{playing_pid}` if playing_pid
        self.playing_pid = nil
      else
        raise NoPlayingPidException, "*** Can't terminate song because can't find playing_pid #{playing_pid} ***"
      end
    end

    def set_player(user_config)
      if music_file =~ /\.mp3$/i
        self.player = user_config.mp3_player
      elsif music_file =~ /\.ogg$/i
        self.player = user_config.ogg_player
      else
        raise UnsupportedSongFormatException, "Attempted to play a file format this program cannot play"
      end
    end

    def play(user_config)
      set_player(user_config)
      process_status = play_with_player
      process_status.exitstatus.to_i == 0 ? (self.playing_pid = nil) : (raise SongTerminatedBadlyException, "Experienced a problem playing a song")
    end

    def play_with_player
      puts "Press Ctrl-C to stop the music and exit this program"
      puts "Now playing '#{music_file}'"
      music_file_path = File.expand_path(music_file)
      system_yield_pid(player, music_file_path) do |pid|
        self.playing_pid = pid 
      end
      Process.waitpid(playing_pid) # Waits for a child process to exit, returns its process id, and sets $? to a Process::Status object
      $? # return Process::Status object with instance methods .stopped?, .exited?, .exitstatus; see: http://www.ruby-doc.org/core/classes/Process/Status.html
    end

  end

  def running_jruby?
    defined?(JRUBY_VERSION) || RUBY_ENGINE == 'jruby' || RUBY_PLATFORM == 'java'
  end

  # make system call and get pid so you can terminate process
  def system_yield_pid(command,arg)
    # would like to use Process.respond_to?(:fork) but JRuby mistakenly returns true
    if running_jruby?
      pid = Spoon.spawnp(command,arg)
    else
      begin
        #spawn(command + ' ' + arg)
        #pid = POSIX::Spawn::spawn(command + ' ' + arg)
        
        # create and run block in subprocess (which will terminate with status 0), capture subprocess pid
        pid = Process.fork do
          exec(command + ' ' + arg)  # replace new process with system call
          exit! 127                  # exit process and return exit status 127; should never be reached
        end
      rescue NotImplementedError
        raise CannotSpawnProcessException, "*** Cannot play music because we found neither Spoon.spawnp (for JRuby) nor Process.fork (for MRI) ***"
      end
    end
    yield pid if block_given? # call block, passing in the subprocess pid
  end

end
