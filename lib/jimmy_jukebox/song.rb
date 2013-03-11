require_relative "display_options"

module JimmyJukebox

  class Song

    include JimmyJukebox::DisplayOptions

    class InvalidSongFormatException < Exception; end
    class NoPlayingPidException < Exception; end
    class UnsupportedSongFormatException < Exception; end
    class CannotSpawnProcessException < Exception; end
    class SongTerminatedPrematurelyException < Exception; end

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

    def <=>(other)
      music_file <=> other.music_file
    end

    def set_music_file(in_music_file)
      if in_music_file =~ /\.mp3$/i || in_music_file =~ /\.ogg$/i
        @music_file = File.expand_path(in_music_file)
      else
        raise InvalidSongFormatException, "JimmyJukebox plays only .mp3/.ogg files. #{in_music_file} is not valid"
      end
    end

    def grandchild_pid
      # returns grandchild's pid if the child process spawns a grandchild
      # if so, the child is probably "/bin/sh" and the grandchild is "mpg123" or similar
      gpid = `ps h --ppid #{playing_pid} -o pid`.strip.to_i
      gpid == 0 ? nil : gpid
    end

    def process_group_id
      Process.getpgid(playing_pid)
    end

    def pause
      self.paused = true
      if grandchild_pid
        `kill -s STOP #{grandchild_pid}`
      elsif playing_pid
        `kill -s STOP #{playing_pid}`
      else
        raise NoPlayingPidException, "*** Can't pause song because can't find playing_pid #{playing_pid} ***"
      end
    end

    def unpause
      self.paused = false
      if grandchild_pid
        `kill -s CONT #{grandchild_pid}`
      elsif playing_pid
        `kill -s CONT #{playing_pid}`
      else
        raise NoPlayingPidException, "*** Can't unpause song because can't find playing_pid #{playing_pid} ***"
      end
    end

    def kill_playing_pid_and_children
      grandpid = grandchild_pid
      playpid = playing_pid
      if grandpid
        `kill #{grandpid}`
      end
      `kill #{playpid}`
    end

    def terminate
      self.paused = false
      self.player = nil
      if playing_pid
        kill_playing_pid_and_children
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

    def pre_command
      if JimmyJukebox::RUNNING_LINUX
        # prevent screen blanking that pauses running song
        puts "*** Preventing screen blanking ***"
        'setterm -blank 0 -powerdown 0 -powersave off; '
      else
        ''
      end
    end

    def spawn_method
      if JimmyJukebox::RUNNING_JRUBY
        lambda { |command, arg| Spoon.spawnp(command, arg) }
      else
        begin
          lambda { |command, arg| POSIX::Spawn::spawn(command + ' ' + arg) }
          
          # posix/spawn is much faster than fork-exec
          #pid = Process.fork do
          #  exec(command + ' ' + arg)
          #end
        rescue NotImplementedError
          raise CannotSpawnProcessException, "*** Cannot play music because we found neither Spoon.spawnp (for JRuby) nor Process.fork (for MRI) ***"
        end
      end
    end

    def play(user_config, jukebox)
      set_player(user_config)
      process_status = play_with_player
      process_status.exitstatus.to_i == 0 ? (self.playing_pid = nil) : (raise SongTerminatedPrematurelyException, "Experienced a problem playing a song")
    end

    def play_with_player
      run_command(player, music_file)
      puts "Now playing '#{music_file}'"
      display_options_after_delay
      Process.waitpid(playing_pid) # Waits for a child process to exit, returns its process id, and sets $? to a Process::Status object
      $? # return Process::Status object with instance methods .stopped?, .exited?, .exitstatus
    end

  end

  def run_command(command, arg)
    # make system call and get pid so you can pause/terminate process
    pid = spawn_method.call(command, arg)
    self.playing_pid = pid
  end

end
