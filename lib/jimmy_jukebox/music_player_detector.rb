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
      elsif cvlc_exists?
        "cvlc --play-and-exit -q"
      elsif amarok_exists?
        "amarok"
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
      elsif cvlc_exists?
        "cvlc --play-and-exit -q"
      elsif amarok_exists?
        "amarok"
      end
    end

    def aac_player
    end

    def wma_player
    end

    def wav_player
      if cvlc_exists?
        "cvlc --play-and-exit -q"
      elsif play_exists?
        "play"
      elsif mplayer_exists?
        "mplayer -nolirc -noconfig all"
      elsif aplay_exists?
        "aplay"
      elsif amarok_exists?
        "amarok"
      end
    end

    def flac_player
      if cvlc_exists?
        "cvlc --play-and-exit -q"
      elsif play_exists?
        "play"
      elsif mplayer_exists?
        "mplayer -nolirc -noconfig all"
      end
    end

    # can't figure out how to play just one song
    def mpc_exists?
      `which mpc`.match(/.*\/mpc$/) ? true : false
    end

    # other players possibly worth enabling
    # https://xmms2.org/wiki/Using_the_application
    
    def cvlc_exists?
      `which cvlc`.match(/.*\/cvlc$/) ? true : false
    end

    def aplay_exists?
      `which aplay`.match(/.*\/aplay$/) ? true : false
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

    def amarok_exists?
      `which amarok`.match(/.*\/amarok$/) ? true : false
    end

  end

end
