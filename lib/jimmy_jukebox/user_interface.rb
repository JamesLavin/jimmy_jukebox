require 'jimmy_jukebox/check_io_console'
require 'jimmy_jukebox/jukebox'
require 'jimmy_jukebox/check_jruby'

jj = Jukebox.new

play_loop_thread = Thread.new do
  at_exit { jj.restore_dpms_state } if JimmyJukebox::RUNNING_LINUX 
  jj.play_loop
end

user_input_thread = Thread.new do
  
  class NoPlayLoopThreadException < Exception; end

  def set_get_char_method
    @get_char_method = if JimmyJukebox::RUNNING_JRUBY
                         lambda { STDIN.getch }
                       else
                         lambda {
                           begin
                             stty_state = `stty -g`
                             system("stty raw opost -echo -icanon isig")
                             STDIN.getc.chr
                           ensure
                             `stty #{stty_state}`
                           end
                         }
                       end
  end

  def get_char
    @get_char_method.call
  end

  begin
    set_get_char_method
    loop do
      case char = get_char
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
        puts "#{char.strip} is not a valid response" if char
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

