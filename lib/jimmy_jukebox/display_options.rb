module JimmyJukebox

  module DisplayOptions
    
    def display_options
      puts "'p' = (un)pause, 'q' = quit, 'r' = replay previous, 's' = skip song, 'e' = erase song, 'b' = from beginning"
    end

    def display_options_after_delay
      # pause to let song display song info and begin playing before displaying user options
      sleep 0.4
      display_options
    end

  end

end

