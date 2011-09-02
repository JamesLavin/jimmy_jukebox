RSpec.configure do |config|
  config.before(:suite) do
    ARGV.clear
  end
end

# Override exec() to prevent songs from actually playing
# Instead, start a brief sleep process
module Kernel
  alias :real_exec :exec

  def exec(*cmd)
    real_exec("sleep 0.2")  
  end
end


