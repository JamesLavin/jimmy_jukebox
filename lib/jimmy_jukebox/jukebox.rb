module JimmyJukebox

  module Jukebox

    class << Jukebox

      attr_accessor :current_song, :continuous_play

    end

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
        terminate_current_song
      else
        raise "No @current_song"
      end
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
      @current_song.play(user_config)
      @current_song = nil # ????
    end

    def self.terminate_current_song
      if @current_song
        puts "Terminating #{@current_song.music_file}"
        @current_song.terminate
        #@current_song = nil
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
