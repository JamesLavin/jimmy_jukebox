require 'jimmy_jukebox/check_io_console'
require 'jimmy_jukebox/jukebox'
require 'jimmy_jukebox/check_jruby'

jj = Jukebox.new

play_loop_thread = Thread.new do
  at_exit { jj.restore_dpms_state } if JimmyJukebox::RUNNING_LINUX 
  jj.play_loop
end

module JimmyJukebox

  class UserInputHandler
  
    class NoPlayLoopThreadException < Exception; end
    
    attr_accessor :jukebox

    def initialize(jukebox)
      self.jukebox = jukebox
    end

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
  
    def repl
      set_get_char_method
      loop do
        case char = get_char
        when "q", "Q"
          raise Interrupt
        when "e", "E"
          jukebox.erase_song
        when "p", "P"
          if jukebox.current_song.paused?
            jukebox.unpause_current_song
          else
            puts "Pausing. To unpause, enter 'p' again"
            jukebox.pause_current_song
          end
        when "r", "R"
          jukebox.replay_previous_song
        when "s", "S"
          jukebox.skip_song
        else
          puts "#{char.strip} is not a valid response" if char
        end
      end
    rescue Interrupt, SystemExit => e
      puts "JimmyJukebox closed by user request. Bye!"
      jukebox.quit
      exit
    end

  end

end

uih = UserInputHandler.new(jj)

user_input_thread = Thread.new do
  
  raise NoPlayLoopThreadException, "Can't find play_loop_thread" unless play_loop_thread
  uih.repl

end

play_loop_thread.join
user_input_thread.join

