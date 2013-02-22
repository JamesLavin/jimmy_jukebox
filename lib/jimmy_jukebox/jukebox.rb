require 'jimmy_jukebox/user_config'

module JimmyJukebox

  class Jukebox

    class NoNewSongException < Exception; end
    class NoCurrentSongException < Exception; end
    class NoPreviousSongException < Exception; end

    attr_accessor :current_song, :continuous_play
    attr_writer   :user_config, :previous_song, :next_song, :playing

    def initialize(new_user_config = UserConfig.new, continuous_play = true)
      self.user_config = new_user_config
      self.continuous_play = continuous_play
    end

    def play_loop
      loop do
        if continuous_play && !playing?
          p "Playing random song"
          play_next_song
        else
          sleep 0.1
        end
      end
    end

    def next_song
      @next_song ? @next_song : random_song
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
      @previous_song || nil
    end

    def replay_previous_song
      if previous_song
        p "Replaying #{previous_song.music_file}"
        #terminate_current_song
        play_song(previous_song)
      else
        raise NoPreviousSongException, "No previous song"
      end
    end

    def skip_song
      enable_continuous_play
      if current_song
        p "Skipping #{current_song.music_file}"
        #play_random_song
        self.previous_song = current_song
        self.current_song = nil
        previous_song.terminate
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
      p "Inside play_random_song"
      play_song(random_song)
    end

    def enable_continuous_play
      self.continuous_play = true
    end

    def disable_continuous_play
      self.continuous_play = false
    end

    def play_song(song)
      disable_continuous_play
      terminate_current_song if current_song
      self.playing = true
      p "Setting current_song = #{song.music_file}"
      self.current_song = song
      current_song.play(user_config, self)
      p "Finished playing"
      self.previous_song = current_song
      self.current_song = nil
      self.playing = false
      enable_continuous_play
    rescue Song::SongTerminatedPrematurelyException
      p "Song ended prematurely"
    end

    def terminate_current_song
      if current_song
        p "Terminating #{current_song.music_file}"
        current_song.terminate
        self.previous_song = current_song
        self.current_song = nil
        self.playing = false
      else
        raise NoCurrentSongException, "No current_song"
      end
    end

    def user_config
      @user_config ||= UserConfig.new
    end

  end

end
