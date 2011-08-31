module JimmyJukebox

  class Song

    attr_reader :paused, :playing_pid, :player, :music_file

    def initialize(music_file)
      @music_file = music_file
      @paused = false
      @playing_pid = nil
    end

    def pause
      @paused = true
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      # system("kill -s STOP #{@playing_pid}") if @playing_pid
      `kill -s STOP #{@playing_pid}` if @playing_pid
    end

    def unpause
      @paused = false
      # jruby doesn't seem to handle system() correctly
      # trying backticks
      #system("kill -s CONT #{@playing_pid}") if @playing_pid
      `kill -s CONT #{@playing_pid}` if @playing_pid
    end

    def terminate
      @paused = false
      #`killall #{@player}`
      @player = nil
      # killing processes seems problematic in JRuby
      # I've tried several approaches, and nothing seems reliable
      #Process.kill("SIGKILL",@playing_pid) if @playing_pid
      #Process.kill("SIGTERM",@playing_pid) if @playing_pid
      `kill #{@playing_pid}` if @playing_pid
      @playing_pid = nil
    end

    def set_player(user_config)
      if @music_file =~ /\.mp3$/i
        @player = user_config.mp3_player
      elsif @music_file =~ /\.ogg$/i
        @player = user_config.ogg_player
      end
      raise "Attempted to play a file format this program cannot play" unless @player
    end

    def play(user_config)
      set_player(user_config)
      process_status = play_with_player
      process_status.exitstatus.to_i == 0 ? (@playing_pid = nil) : (raise "Experienced a problem playing a song")
    end

    private

    def play_with_player
      puts "Press Ctrl-C to stop the music and exit this program"
      puts "Now playing '#{@music_file}'"
      puts "#{@player} \"#{File.expand_path(@music_file)}\""
      system_yield_pid(@player, File.expand_path(@music_file)) do |pid|
        @playing_pid = pid 
      end
    end

  end

end
