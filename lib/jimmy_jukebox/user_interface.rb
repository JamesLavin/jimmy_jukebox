require 'readline'

stty_save = `stty -g`.chomp   # Store state of the terminal

jj = Jukebox.new

play_loop_thread = Thread.new do
  jj.play_loop
end

def display_options_after_delay
  sleep 0.1
  p "Press 'p' to (un)pause, 'q' to quit, 'r' for replay previous song, or 's' to skip this song"
end

begin
  class NoPlayLoopThreadException < Exception; end

  while true do
    display_options_after_delay
    line = Readline.readline('> ', true)
    case line.strip
    when "q", "Q"
      p "Quit requested"
      jj.quit
      Thread.main.exit
    when "p", "P"
      raise NoPlayLoopThreadException, "Can't find play_loop_thread" unless play_loop_thread
      if jj.current_song.paused?
        p "Unpause requested"
        jj.unpause_current_song
      else
        p "Pause requested"
        p "To unpause, enter 'p' again"
        jj.pause_current_song
      end
    when "r", "R"
      p "Replay previous song requested"
      jj.replay_previous_song
    when "s", "S"
      p "Skip song requested"
      jj.skip_song
    else
      p "#{line.strip} is not a valid response"
    end
  end
rescue Interrupt, SystemExit => e
  p "JimmyJukebox closed by user request. Bye!"
  system('stty', stty_save) # Restore original terminal state
  exit
end

play_loop_thread.join

