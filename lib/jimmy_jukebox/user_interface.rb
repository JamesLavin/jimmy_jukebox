require 'readline'

class NoPlayLoopThreadException < Exception; end

# Store the state of the terminal
stty_save = `stty -g`.chomp

jj = Jukebox.new

play_loop_thread = Thread.new do
  jj.play_loop
end

display_string = "Press 'p' to (un)pause, 'q' to quit, or 's' to skip the song"
begin
  while true do
    puts display_string
    line = Readline.readline('> ', true)
    case line.strip
    when "q"
      puts "Quit requested"
      jj.quit
      Thread.main.exit
    when "p"
      raise NoPlayLoopThreadException, "Can't find play_loop_thread" unless play_loop_thread
      if jj.current_song.paused?
        puts "Unpause requested"
        jj.unpause_current_song
      else
        puts "Pause requested"
        jj.pause_current_song
      end
      puts display_string
    when "s"
      puts "Skip song requested"
      jj.skip_song
    else
      puts display_string
    end
  end
rescue Interrupt => e
  system('stty', stty_save) # Restore
  exit
end

play_loop_thread.join

