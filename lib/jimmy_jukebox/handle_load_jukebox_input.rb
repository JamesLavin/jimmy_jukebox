module JimmyJukebox

  module HandleLoadJukeboxInput

    def no_argv0
      puts "You must select an artist to use 'load_jukebox'."
      puts "For example: 'load_jukebox at' to load Art Tatum"
      puts "Another example: 'load_jukebox dr' to load Django Reinhardt"
      exit
    end

    def invalid_artist
      puts "No action taken in response to your command 'load_jukebox #{ARGV[0]}'."
      puts "JimmyJukebox does not recognize '#{ARGV[0]}'. You must select a valid artist."
      puts "For example, valid artists include: 'bh' for Billie Holiday, 'cb' for Count Basie, and 'lh' for Lionel Hampton"
      puts "Please see the README for a complete list of valid artists."
      exit
    end

    def valid_artist?(arg)
      ARTISTS.has_key?(arg.to_sym)
    end

    def valid_genre?(arg)
      # probably shouldn't hardcode these
      valid_genres = [/^JAZZ$/i, /^CLASSICAL$/i, /^BLUEGRASS$/i, /^BANJO$/i, /^ROCK$/i]
      valid_genres.any? { |g| g =~ arg }
    end

    def radio?(arg)
      arg && arg =~ /^radio$/i
    end

    def artist_name(arg)
      ARTISTS[arg.to_sym][:name]
    end

    def valid_integer?(arg)
      arg && arg.to_i.is_a?(Integer) && arg.to_i > 0
    end

    def play_radio
      require 'jimmy_jukebox/check_gems'
      require 'jimmy_jukebox/user_interface'
      #jj = Jukebox.new
      #play_loop_thread = Thread.new do
      #  jj.play_loop
      #end
      #play_loop_thread.join
    end

    def process_artist
      if valid_integer?(ARGV[1])
        JimmyJukebox::SongLoader.new.send(artist_name(ARGV[0]), ARGV[1].to_i)
      else
        JimmyJukebox::SongLoader.new.send(artist_name(ARGV[0]))
      end
    end

    def process_sample
      if ARGV[1].nil?
        JimmyJukebox::SongLoader.new.download_sample_genre(1)
      elsif valid_integer?(ARGV[1]) && valid_genre?(ARGV[2])
        JimmyJukebox::SongLoader.new.download_sample_genre(ARGV[1].to_i, ARGV[2].upcase)
      elsif valid_genre?(ARGV[1]) && valid_integer?(ARGV[2])
        JimmyJukebox::SongLoader.new.download_sample_genre(ARGV[2].to_i, ARGV[1].upcase)
      elsif valid_integer?(ARGV[1])
        JimmyJukebox::SongLoader.new.download_sample_genre(ARGV[1].to_i)
      elsif valid_genre?(ARGV[1])
        JimmyJukebox::SongLoader.new.download_sample_genre(1, ARGV[1].upcase)
      else
        JimmyJukebox::SongLoader.new.download_sample_genre(1)
      end
    end

  end

end
