module JimmyJukebox

  class UserConfig

    attr_reader :mp3_player, :ogg_player

    DEFAULT_MP3_DIR = File.expand_path(File.join("~","Music"))
    DEFAULT_PLAYLIST_DIR = File.expand_path(File.join("~",".jimmy_jukebox"))

    def initialize
      #configure_preferences
      set_music_players
    end

    #def configure_preferences
    #  File.exists?(File.join("~",".jimmy_jukebox","configuration"))
    #end

    def default_mp3_dir
      DEFAULT_MP3_DIR
    end

    def set_music_players
      set_ogg_player
      set_mp3_player
      no_player_configured if !@ogg_player && !@mp3_player
      warn_about_partial_functionality if !@ogg_player || !@mp3_player
    end

    def no_player_configured
      puts "*** YOU CANNOT PLAY MP3S OR OGG FILES -- YOU MIGHT WANT TO INSTALL ogg123 AND mpg123/mpg321 BEFORE USING JIMMYJUKEBOX ***"
      exit
    end

    def warn_about_partial_functionality
      if @ogg_player && !@mp3_player
        puts "*** YOU CANNOT PLAY MP3S -- YOU MIGHT WANT TO INSTALL MPG123 OR MPG321 ***"
      elsif @mp3_player && !@ogg_player
        puts "*** YOU CANNOT PLAY OGG FILES -- YOU MIGHT WANT TO INSTALL OGG123 ***"
      end
    end

    def set_ogg_player
      if ogg123_exists?
        @ogg_player = "ogg123"
        return
      elsif music123_exists?
        @ogg_player = "music123"
        return
      elsif afplay_exists?
        @ogg_player = "afplay"
        return
      elsif mplayer_exists?
        @ogg_player = "mplayer -nolirc -noconfig all"
      elsif play_exists?
        @ogg_player = "play"
      #elsif RUBY_PLATFORM.downcase.include?('mac') || RUBY_PLATFORM.downcase.include?('darwin')
      #  @ogg_player = "afplay"
      #  return
      #elsif (require 'rbconfig') && ['mac','darwin'].include?(RbConfig::CONFIG['host_os'])
      #  @ogg_player = "afplay"
      end
    end

    def set_mp3_player
      if mpg123_exists?
        @mp3_player = "mpg123"
        return
      elsif mpg321_exists?
        @mp3_player = "mpg321"
        return
      elsif music123_exists?
        @mp3_player = "music123"
        return
      elsif afplay_exists?
        @mp3_player = "afplay"
        return
      elsif mplayer_exists?
        @mp3_player = "mplayer -nolirc -noconfig all"
      elsif play_exists?
        @mp3_player = "play"
      #elsif RUBY_PLATFORM.downcase.include?('mac') || RUBY_PLATFORM.downcase.include?('darwin')
      #  @mp3_player = "afplay"
      #  return
      #elsif (require 'rbconfig') && ['mac','darwin'].include?(RbConfig::CONFIG['host_os'])
      #  @mp3_player = "afplay"
      end
    end

    def ogg123_exists?
      `which ogg123`.match(/.*\/ogg123$/) ? true : false
    end

    def mpg123_exists?
      `which mpg123`.match(/.*\/mpg123$/) ? true : false
    end

    def music123_exists?
      `which music123`.match(/.*\/music123$/) ? true : false
    end

    def mpg321_exists?
      `which mpg321`.match(/.*\/mpg321$/) ? true : false
    end

    def afplay_exists?
      `which afplay`.match(/.*\/afplay$/) ? true : false
    end

    def mplayer_exists?
      `which mplayer`.match(/.*\/mplayer$/) ? true : false
    end

    def play_exists?
      `which play`.match(/.*\/play$/) ? true : false
    end

    def set_music_directories_from_file
      if File.exists?(File.expand_path(ARGV[0]))
        @music_directories_file = File.expand_path(ARGV[0])
      elsif File.exists?( File.expand_path( File.join(DEFAULT_PLAYLIST_DIR, ARGV[0]) ) )
        @music_directories_file = File.expand_path(File.join(DEFAULT_PLAYLIST_DIR, ARGV[0]))
      end
      load_top_level_directories_from_file
    end

  end

end 
