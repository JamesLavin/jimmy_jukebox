require 'io/console'

jj = Jukebox.new

play_loop_thread = Thread.new do
  jj.play_loop
end

user_input_thread = Thread.new do
  
  def display_options
    puts "'p' = (un)pause, 'q' = quit, 'r' = replay previous song, 's' = skip this song, 'e' = erase this song"
  end

  def display_options_after_delay
    # pause to let song begin playing (and display song info) before displaying user options
    sleep 0.2
    display_options
  end

  class NoPlayLoopThreadException < Exception; end

  begin
    loop do
      display_options_after_delay
      begin
        system("stty raw opost -echo")
        char = STDIN.getc
      ensure
        system("stty -raw echo")
      end
      case char
      when "q", "Q"
        raise Interrupt
      when "e", "E"
        jj.erase_song
      when "p", "P"
        raise NoPlayLoopThreadException, "Can't find play_loop_thread" unless play_loop_thread
        if jj.current_song.paused?
          jj.unpause_current_song
        else
          puts "Pausing. To unpause, enter 'p' again"
          jj.pause_current_song
        end
      when "r", "R"
        jj.replay_previous_song
      when "s", "S"
        jj.skip_song
      else
        puts "#{line.strip} is not a valid response"
      end
    end
  rescue Interrupt, SystemExit => e
    puts "JimmyJukebox closed by user request. Bye!"
    jj.quit
    exit
  end
end

play_loop_thread.join
user_input_thread.join

