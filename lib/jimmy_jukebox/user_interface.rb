require 'jimmy_jukebox/user_input_handler'

jj = Jukebox.new

play_loop_thread = Thread.new do
  at_exit { jj.restore_dpms_state } if JimmyJukebox::RUNNING_LINUX 
  jj.play_loop
end

uih = UserInputHandler.new(jj)

user_input_thread = Thread.new do
  
  raise NoPlayLoopThreadException, "Can't find play_loop_thread" unless play_loop_thread
  uih.repl

end

play_loop_thread.join
user_input_thread.join

