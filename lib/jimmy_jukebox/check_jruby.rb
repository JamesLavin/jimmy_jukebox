if JimmyJukebox::RUNNING_JRUBY
  class IO
    def getch
      raw do
        getc
      end
    end
  end
end
