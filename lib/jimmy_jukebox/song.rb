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
      self.music_file = in_music_file
      self.paused = false
      self.playing_pid = nil
    end

    def paused?
      @paused
    end

    def <=>(other)
      music_file <=> other.music_file
    end

    def valid_audio_format?(music_file)
      AUDIO_FORMATS.keys.any? { |re| re =~ music_file }
    end

    def music_file=(in_music_file)
      if valid_audio_format?(in_music_file)
        @music_file = File.expand_path(in_music_file)
      else
        raise InvalidSongFormatException, "JimmyJukebox plays only .mp3/.ogg/.flac/.wav files. #{in_music_file} is not valid"
      end
    end

    def grandchild_pid
      # returns grandchild's pid if the child process spawns a grandchild
      # if so, the child is probably "/bin/sh" and the grandchild is "mpg123" or similar
      gpid = JimmyJukebox::RUNNING_LINUX && `ps --ppid #{playing_pid} -o pid`.strip.to_i
      gpid == 0 ? nil : gpid
    end

    def process_group_id
      Process.getpgid(playing_pid)
    end

    def pause
      self.paused = true
      if playing_pid
        if grandchild_pid
          `kill -s STOP #{grandchild_pid}`
        else
          `kill -s STOP #{playing_pid}`
        end
      else
        raise NoPlayingPidException, "*** Can't pause song because can't find playing_pid #{playing_pid} ***"
      end
    end

    def unpause
      self.paused = false
      if playing_pid
        if grandchild_pid
          `kill -s CONT #{grandchild_pid}`
        else playing_pid
          `kill -s CONT #{playing_pid}`
        end
      else
        raise NoPlayingPidException, "*** Can't unpause song because can't find playing_pid #{playing_pid} ***"
      end
    end

    def kill_playing_pid_and_children
      return nil unless playpid = playing_pid
      grandpid = grandchild_pid
      `kill #{grandpid}` if grandpid
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
      if regex = AUDIO_FORMATS.keys.detect { |re| music_file =~ re }
        self.player = user_config.send(AUDIO_FORMATS[regex] + '_player')
      else
        raise UnsupportedSongFormatException, "Attempted to play a file format this program cannot play"
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
      escaped_music_file = escape_characters_in_string(music_file)
      run_command(player, escaped_music_file)
      puts "Now playing '#{music_file}'"
      display_options_after_delay
      Process.waitpid(playing_pid) # Waits for a child process to exit, returns its process id, and sets $? to a Process::Status object
      $? # return Process::Status object with instance methods .stopped?, .exited?, .exitstatus
    end

    private

    def escape_characters_in_string(string)
      pattern = /( |\'|\"|\-|\)|\$|\+|\(|\?|\!|\`)/
      string.gsub(pattern) { |match| "\\"  + match }
    end

  end

  def run_command(command, arg)
    # make system call and get pid so you can pause/terminate process
    pid = spawn_method.call(command, arg)
    self.playing_pid = pid
  end

end
