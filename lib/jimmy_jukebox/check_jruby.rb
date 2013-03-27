if JimmyJukebox::RUNNING_JRUBY
  puts "running JRuby"
  class IO
    def getch
      raw do
        getc
      end
    end
  end
end
