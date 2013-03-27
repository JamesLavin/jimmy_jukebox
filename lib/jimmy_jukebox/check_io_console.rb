begin
  require 'io/console'
rescue LoadError
  puts "*** JimmyJukebox uses io/console, which is built into Ruby 1.9.3. I recommend running JimmyJukebox on 1.9.3. You could instead install the 'io-console' gem, but the most recent version works only with 1.9.3, so try \"gem install io-console -v '0.3'\" ***"
  exit
end
