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
      while continuous_play do
        begin
          play_once
        rescue NoNewSongException => e
          puts e.message
          sleep 1
        end
      end
    rescue SystemExit, Interrupt => e
      terminate_current_song
      puts "\nMusic terminated by user"
      exit
    end

    def play_once
      play_random_song
    end

    def quit
      stop_looping
      terminate_current_song
    end

    def skip_song
      if current_song
        puts "Skipping #{current_song.music_file}"
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
      #current_song = nil # ????
    end

    def terminate_current_song
      if current_song
        puts "Terminating #{current_song.music_file}"
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
