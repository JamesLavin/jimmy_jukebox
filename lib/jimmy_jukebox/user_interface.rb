require 'readline'

stty_save = `stty -g`.chomp   # Store state of the terminal

jj = Jukebox.new

play_loop_thread = Thread.new do
  jj.play_loop
end

def display_options_after_delay
  sleep 0.1
  p "Press 'p' to (un)pause, 'q' to quit, or 's' to skip the song"
end

begin
  class NoPlayLoopThreadException < Exception; end
  display_options_after_delay

  while true do
    line = Readline.readline('> ', true)
    case line.strip
    when "q"
      p "Quit requested"
      jj.quit
      Thread.main.exit
    when "p"
      raise NoPlayLoopThreadException, "Can't find play_loop_thread" unless play_loop_thread
      if jj.current_song.paused?
        p "Unpause requested"
        jj.unpause_current_song
      else
        p "Pause requested"
        p "To unpause, enter 'p' again"
        jj.pause_current_song
      end
    when "s"
      p "Skip song requested"
      jj.skip_song
    else
      p "#{line.strip} is not a valid response"
    end
    display_options_after_delay
  end
rescue Interrupt => e
  system('stty', stty_save) # Restore original terminal state
  exit
end

play_loop_thread.join

