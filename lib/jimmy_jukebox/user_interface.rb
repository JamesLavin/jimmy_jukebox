begin
  require 'io/console'
rescue LoadError
  puts "*** JimmyJukebox uses io/console, which is built into Ruby 1.9.3. I recommend running JimmyJukebox on 1.9.3. You could instead install the 'io-console' gem, but the most recent version works only with 1.9.3, so try \"gem install io-console -v '0.3'\" ***"
  exit
end

require 'jimmy_jukebox/jukebox'

if JimmyJukebox::RUNNING_JRUBY
  class IO
    def getch
      raw do
        getc
      end
    end
  end
end

jj = Jukebox.new

play_loop_thread = Thread.new do
  at_exit { jj.restore_dpms_state } if JimmyJukebox::RUNNING_LINUX 
  jj.play_loop
end

user_input_thread = Thread.new do
  
  class NoPlayLoopThreadException < Exception; end

  begin
    loop do
      if JimmyJukebox::RUNNING_JRUBY
        char = STDIN.getch
      else
        begin
          stty_state = `stty -g`
          system("stty raw opost -echo -icanon isig")
          char = STDIN.getc.chr
        ensure
          `stty #{stty_state}`
        end
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

