require 'jimmy_jukebox/user_config'

module JimmyJukebox

  class Jukebox

    class NoNewSongException < Exception; end
    class NoCurrentSongException < Exception; end

    attr_accessor :current_song, :continuous_play
    attr_writer   :user_config

    def initialize(new_user_config = UserConfig.new, continuous_play = true)
      self.user_config = new_user_config
      self.continuous_play = continuous_play
    end

    def play_loop
      play_random_song while continuous_play
    rescue SystemExit, Interrupt => e
      terminate_current_song
      p "\nJimmyJukebox closed by user request. Bye!"
      exit
    end

    def quit
      stop_looping
      terminate_current_song
    end

    def skip_song
      if current_song
        p "Skipping #{current_song.music_file}"
        terminate_current_song
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

    def play_random_song
      raise NoNewSongException, "JimmyJukebox can't find any songs to play!" if songs.length == 0
      self.current_song = Song.new( songs[rand(songs.length)] )
      current_song.play(user_config)
    end

    def terminate_current_song
      if current_song
        p "Terminating #{current_song.music_file}"
        current_song.terminate
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
