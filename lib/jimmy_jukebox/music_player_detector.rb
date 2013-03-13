module JimmyJukebox

  class MusicPlayerDetector

    def ogg_player
      if ogg123_exists?
        "ogg123"
      elsif music123_exists?
        "music123"
      elsif afplay_exists?
        "afplay"
      elsif mplayer_exists?
        "mplayer -nolirc -noconfig all"
      elsif play_exists?
        "play"
      end
    end

    def mp3_player
      if mpg123_exists?
        "mpg123"
      elsif mpg321_exists?
        "mpg321"
      elsif music123_exists?
        "music123"
      elsif afplay_exists?
        "afplay"
      elsif mplayer_exists?
        "mplayer -nolirc -noconfig all"
      elsif play_exists?
        "play"
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

  end

end
