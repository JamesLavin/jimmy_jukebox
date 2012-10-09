RSpec.configure do |config|
  config.before(:suite) do
    ARGV.clear
  end
end

require 'fakefs/spec_helpers'

# Overriding FakeFS' File.expand_path
# because it delegates to the same class
# method in the REAL file system
module FakeFS
  class File
    def self.expand_path(*args)
      args[0].gsub(/~/,'/home/xavier')
    end
  end
  # Started overriding FileUtils.ln because FakeFS doesn't know about it
  # Instead switched to using File.link, which FakeFS knows about
end

# Overriding File.expand_path
# so it will provide the fake user's
# home directory
class File
  def self.expand_path(*args)
    args[0].gsub(/~/,'/home/xavier')
  end
end

# Override exec() to prevent songs from actually playing
# Instead, start a brief sleep process
#module Kernel
#  alias :real_exec :exec
#
#  def exec(*cmd)
#    real_exec("sleep 0.2")  
#  end
#end


