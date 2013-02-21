require 'jimmy_jukebox/user_config'

module JimmyJukebox

  class Jukebox

    class NoNewSongException < Exception; end
    class NoCurrentSongException < Exception; end
    class NoPreviousSongException < Exception; end

    attr_accessor :current_song, :continuous_play
    attr_writer   :user_config, :previous_song, :auto_play

    def initialize(new_user_config = UserConfig.new, continuous_play = true)
      self.user_config = new_user_config
      self.continuous_play = continuous_play
    end

    def play_loop
      while continuous_play
        unless auto_play
          sleep 0.5
        else
          p "Playing random song"
          play_random_song
        end
      end
    #rescue SystemExit, Interrupt => e
    #  terminate_current_song
    #  p "\nJimmyJukebox closed by user request. Bye!"
    #  exit
    end

    def quit
      stop_looping
      terminate_current_song
    end

    def auto_play
      @auto_play ||= true
    end

    def previous_song
      @previous_song || nil
    end

    def replay_previous_song
      if previous_song
        p "Replaying #{previous_song.music_file}"
        self.auto_play = false
        #terminate_current_song
        play_song(previous_song)
        self.auto_play = true
      else
        raise NoPreviousSongException, "No previous song"
      end
    end

    def skip_song
      if current_song
        p "Skipping #{current_song.music_file}"
        self.previous_song = current_song
        current_song.terminate
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

    def stop_looping
      self.continuous_play = false
    end

    def songs
      user_config.songs
    end

    def random_song
      raise NoNewSongException, "JimmyJukebox can't find any songs to play!" if songs.length == 0
      Song.new( songs[rand(songs.length)] )
    end

    def play_random_song
      p "Inside play_random_song"
      play_song(random_song)
    end

    def play_song(song)
      terminate_current_song if current_song
      p "Setting current_song = #{song.music_file}"
      self.current_song = song
      current_song.play(user_config, self)
      self.previous_song = current_song
      self.current_song = nil
    end

    def terminate_current_song
      if current_song
        p "Terminating #{current_song.music_file}"
        self.auto_play = false
        current_song.terminate
        self.previous_song = current_song
        self.current_song = nil
      else
        raise NoCurrentSongException, "No current_song"
      end
    end

    def user_config
      @user_config ||= UserConfig.new
    end

  end

end
