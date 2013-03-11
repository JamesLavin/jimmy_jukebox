require 'jimmy_jukebox/user_config'

module JimmyJukebox

  class Jukebox

    class NoSongsException < Exception; end
    class NoNewSongException < Exception; end
    class NoCurrentSongException < Exception; end
    class NoPreviousSongException < Exception; end
    class NotRunningXWindowsException < Exception; end

    attr_accessor :current_song, :continuous_play, :songs_played, :initial_dpms_state
    attr_writer   :user_config, :next_song, :playing

    def dpms_state
      raise NotRunningXWindowsException unless JimmyJukebox::RUNNING_X_WINDOWS
      xsettings = `xset q`
      xsettings.match(/DPMS is (.*)/)[1]
    end

    def restore_dpms_state
      raise NotRunningXWindowsException unless JimmyJukebox::RUNNING_X_WINDOWS
      puts "*** Restoring DPMS state to 'Enabled' ***"
      `xset +dpms` if initial_dpms_state == 'Enabled'
    end

    def disable_monitor_powerdown
      raise NotRunningXWindowsException unless JimmyJukebox::RUNNING_X_WINDOWS
      self.initial_dpms_state = dpms_state
      puts "*** Disabling DPMS. Will re-enable DPMS on shutdown ***" if initial_dpms_state == 'Enabled'
      `xset -dpms` #`; xset s off`
    end

    def initialize(new_user_config = UserConfig.new, continuous_play = true)
      disable_monitor_powerdown if JimmyJukebox::RUNNING_X_WINDOWS
      self.user_config = new_user_config
      self.continuous_play = continuous_play
      raise NoSongsException if songs.empty?
    end

    def play_loop
      loop do
        if continuous_play && !playing?
          play_next_song
        else
          sleep 0.1
        end
      end
    end

    def next_song
      # reset @next_song each time it's accessed
      current_next_song = @next_song ? @next_song : random_song
      @next_song = random_song
      current_next_song
    end

    def play_next_song
      play_song(next_song)
    end

    def quit
      disable_continuous_play
      terminate_current_song
    end

    def playing?
      @playing ||= false
    end

    def previous_song
      if songs_played.length >= 2
        songs_played[songs_played.length-2]
      else
        nil
      end
    end

    def songs_played
      @songs_played ||= []
    end

    def replay_previous_song
      if previous_song && current_song
        enable_continuous_play
        self.next_song = previous_song
        puts "Replaying #{previous_song.music_file}"
        current_song.terminate
        self.current_song = nil
        self.playing = false
      else
        raise NoPreviousSongException, "No previous song"
      end
    end

    def erase_song
      if current_song
        song_to_erase = current_song
        skip_song
        File.delete(song_to_erase.music_file)
        puts "Erased #{song_to_erase.music_file}"
        user_config.generate_song_list
      else
        raise NoCurrentSongException, "No current_song"
      end
    end

    def skip_song
      if current_song
        enable_continuous_play
        puts "Skipping #{current_song.music_file}"
        current_song.terminate
        self.current_song = nil
        self.playing = false
      else
        raise NoCurrentSongException, "No current_song"
      end
    end

    def pause_current_song
      current_song.pause
    end

    def unpause_current_song
      current_song.unpause
    end

    def songs
      user_config.songs
    end

    def random_song
      raise NoNewSongException, "JimmyJukebox can't find any songs to play!" if songs.length == 0
      Song.new( songs[rand(songs.length)] )
    end

    def play_random_song
      play_song(random_song)
    end

    def enable_continuous_play
      self.continuous_play = true
    end

    def disable_continuous_play
      self.continuous_play = false
    end

    def play_song(song)
      self.playing = true
      terminate_current_song(play_another: false) if current_song
      self.current_song = song
      self.songs_played << song
      current_song.play(user_config, self)
      puts "Finished playing"
      self.current_song = nil
      self.playing = false
    rescue Song::SongTerminatedPrematurelyException
    ensure
      puts "-------------------------------------"
    end

    def terminate_current_song(opts=nil)
      # By default, stops song and lets a new song play automatically
      # To prevent another song from playing automatically, pass "play_another: false"
      if current_song
        puts "Terminating #{current_song.music_file}"
        current_song.terminate
        self.current_song = nil
        self.playing = (opts && opts[:play_another]) ? !play_another : false
      else
        raise NoCurrentSongException, "No current_song"
      end
    end

    def user_config
      @user_config ||= UserConfig.new
    end

  end

end
