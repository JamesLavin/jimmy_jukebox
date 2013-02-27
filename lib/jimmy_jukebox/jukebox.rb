require 'jimmy_jukebox/user_config'

module JimmyJukebox

  RUNNING_JRUBY = defined?(JRUBY_VERSION) || (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby') || RUBY_PLATFORM == 'java'

  class Jukebox

    class NoSongsException < Exception; end
    class NoNewSongException < Exception; end
    class NoCurrentSongException < Exception; end
    class NoPreviousSongException < Exception; end

    attr_accessor :current_song, :continuous_play, :songs_played
    attr_writer   :user_config, :next_song, :playing

    def initialize(new_user_config = UserConfig.new, continuous_play = true)
      self.user_config = new_user_config
      self.continuous_play = continuous_play
      raise NoSongsException if songs.empty?
    end

    def play_loop
      loop do
        if continuous_play && !playing?
          p "Playing next song"
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
        p "Replaying #{previous_song.music_file}"
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
        p "Erased #{song_to_erase.music_file}"
        user_config.generate_song_list
      else
        raise NoCurrentSongException, "No current_song"
      end
    end

    def skip_song
      if current_song
        enable_continuous_play
        p "Skipping #{current_song.music_file}"
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
      p "Finished playing"
      #p "Songs played: " + songs_played.to_s
      self.current_song = nil
      self.playing = false
    rescue Song::SongTerminatedPrematurelyException
      p "Song ended prematurely"
    end

    def terminate_current_song(opts=nil)
      # By default, stops song and lets a new song play automatically
      # To prevent another song from playing automatically, pass "play_another: false"
      if current_song
        p "Terminating #{current_song.music_file}"
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
