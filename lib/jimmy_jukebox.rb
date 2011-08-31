module JimmyJukebox

  # make system call and get pid so you can terminate process
  def system_yield_pid(player, filename)
    # would like to use Process.respond_to?(:fork) but JRuby mistakenly returns true
    if (defined?(JRUBY_VERSION) || RUBY_PLATFORM == 'java')
      pid = Spoon.spawnp("#{player} #{filename}")
    else
      begin
        pid = fork do             # creates and runs block in subprocess (which will terminate with status 0), capture subprocess pid
          exec(player,filename)   # replaces current process with system call
          exit! 127               # exit process and return exit status 127; should never be reached
        end
      rescue NotImplementedError
        raise "*** fork()...exec() not supported ***"
      end
    end
    if pid
      puts "pid: #{pid}"
    else
      puts "No process id (pid)!"
      raise "@current_song: #{@current_song.inspect}"
    end
    yield pid if block_given? # call block, passing in the subprocess pid
    Process.waitpid(pid)      # Waits for a child process to exit, returns its process id, and sets $? to a Process::Status object
    $?                        # return Process::Status object with instance methods .stopped?, .exited?, .exitstatus; see: http://www.ruby-doc.org/core/classes/Process/Status.html
  end

  module Jukebox

    require 'jimmy_jukebox/user_config'
    require 'jimmy_jukebox/song'

    attr_reader :continuous_play, :current_song

    def self.play_loop
      @continuous_play = true
      while @continuous_play do
        play_once
      end
    end

    def self.play_once
      begin
        play_random_song
      rescue SystemExit, Interrupt => e
        terminate_current_song
        puts "\nMusic terminated by user"
        exit
      end
    end

    def self.quit
      stop_looping
      terminate_current_song
    end

    def self.skip_song
      if @current_song
        puts "Terminating #{@current_song.music_file}"
      else
        raise "No @current_song"
      end
      terminate_current_song
    end

    def self.pause_current_song
      @current_song.pause
    end

    def self.unpause_current_song
      @current_song.unpause
    end

    def self.stop_looping
      @continuous_play = false
    end

    def self.songs
      user_config.songs
    end

    def self.play_random_song
      #terminate_current_song
      raise "JimmyJukebox has no songs to play!" if songs.length == 0
      @current_song = Song.new( songs[rand(songs.length)] )
      puts @current_song.inspect
      @current_song.play(user_config)
      @current_song.terminate # ????
      @current_song = nil # ????
    end

    def self.terminate_current_song
      if @current_song
        puts "Terminating #{@current_song.music_file}"
        @current_song.terminate
        @current_song = nil
      else
        puts "No song is currently playing"
      end
    end

    def self.user_config
      @user_config = UserConfig.new unless @user_config
      @user_config
    end

  end

end
