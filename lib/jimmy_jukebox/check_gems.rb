$running_jruby = defined?(JRUBY_VERSION) || (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby') || RUBY_PLATFORM == 'java'

if $running_jruby
  begin
    require 'spoon'
  rescue LoadError => e
    if e.message =~ /spoon/
      puts "*** You must run 'gem install spoon' before using JimmyJukebox on JRuby ***"
      exit
    else
      raise
    end
  end
else
  begin
    require 'posix/spawn'
  rescue LoadError => e
    if e.message =~ /posix/ || e.message =~ /spawn/
      puts "*** You must run 'gem install posix-spawn' before using JimmyJukebox in Ruby ***"
      exit
    else
      raise
    end
  end
end
