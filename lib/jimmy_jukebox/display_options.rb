module JimmyJukebox

  module DisplayOptions
    
    def display_options
      puts "'p' = (un)pause, 'q' = quit, 'r' = replay previous song, 's' = skip this song, 'e' = erase this song"
    end

    def display_options_after_delay
      # pause to let song display song info and begin playing before displaying user options
      sleep 1
      display_options
    end

  end

end

