require 'jimmy_jukebox/artists'

module JimmyJukebox

  module HandleLoadJukeboxInput

    def no_argv0
      display_template {
        puts "    You must select an artist or genre to use 'load_jukebox'.\n\n"
        puts "    Examples:\n\n"
        puts "         load_jukebox at            (to download Art Tatum)\n\n"
        puts "         load_jukebox dr            (to download Django Reinhardt)\n\n"
        puts "         load_jukebox bluegrass     (to download bluegrass)\n\n"
        puts "         load_jukebox classical     (to download classical)\n\n"
        puts "         load_jukebox jazz          (to download jazz)\n\n"
      }
      exit
    end

    def list_artists
      display_template {
        puts "    Artist symbol = Artist name (Genre)\n\n"
        ARTISTS.each do |k,v|
          puts "            " + k.to_s.rjust(5) + ' = ' + prettified_artist_name(v[:name]) + ' (' + v[:genre].capitalize + ')'
        end
        puts "\n"
      }
    end

    def invalid_artist
      display_template {
        puts "    No action taken in response to your command 'load_jukebox #{ARGV[0]}'.\n\n"
        puts "    JimmyJukebox does not recognize '#{ARGV[0]}'.\n\n"
        puts "    You must select a valid artist or genre.\n\n"
        puts "    Valid genres:\n\n"
        puts "         'bluegrass'"
        puts "         'banjo'"
        puts "         'classical'"
        puts "         'jazz'"
        puts "         'rock'\n\n"
        puts "    Valid artists include:\n\n"
        puts "         'bh' for Billie Holiday"
        puts "         'cb' for Count Basie"
        puts "         'lh' for Lionel Hampton.\n\n"
        puts "    Please visit the link below for a complete list of valid artists.\n\n"
      }
      exit
    end

    def valid_artist?(arg)
      ARTISTS.has_key?(arg.to_sym)
    end

    def valid_genre?(arg)
      # probably shouldn't hardcode these
      valid_genres = [/^BANJO$/i, /^BLUEGRASS$/i, /^CLASSICAL$/i, /^FOLK$/i, /^JAZZ$/i, /^JUGBAND$/i, /^ROCK$/i]
      valid_genres.any? { |g| g =~ arg }
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
    end

    def process_artist
      if valid_integer?(ARGV[1])
        JimmyJukebox::SongLoader.new.send(artist_name(ARGV[0]), ARGV[1].to_i)
      else
        JimmyJukebox::SongLoader.new.send(artist_name(ARGV[0]))
      end
    end

    def process_genre
      if valid_integer?(ARGV[1])
        JimmyJukebox::SongLoader.new.download_sample_genre(ARGV[1].to_i, ARGV[0].upcase)
      else
        display_genre_download_requires_n_message
      end
    end

    def display_template(&msg)
      puts "    ------------------------------------------------------------------------"
      puts "                     JimmyJukebox usage help\n\n"
      msg.call if msg
      puts "    Full instructions: https://github.com/JamesLavin/jimmy_jukebox#readme"
      puts "    ------------------------------------------------------------------------"
    end

    def display_genre_download_requires_n_message
      display_template {
        puts "    You requested a sample of #{ARGV[0]} songs without specifying how many.\n\n"
        puts "    Please try again but specify how many songs you wish to download.\n\n"
        puts "    For example, to download 10 #{ARGV[0]} songs, type:\n\n"
        puts "         load_jukebox #{ARGV[0]} 10"
      }
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
