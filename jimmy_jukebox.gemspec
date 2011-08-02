require 'lib/jimmy_jukebox/version'

spec = Gem::Specification.new do |s|  
  s.name = 'jimmy_jukebox'
  s.author = 'James Lavin'
  s.add_development_dependency('rspec')
  # s.add_dependency
  s.description = 'jimmy_jukebox randomly plays MP3 songs under a directory or set of directories'
  s.email = 'james@jameslavin.com'
  s.files = Dir['lib/**/*.rb']
  #s.homepage = 
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.bindir = 'bin'
  s.executables = ['play_jukebox.rb']
  s.summary = 'plays MP3s in directory/directories of your choosing in a random order'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = JimmyJukebox::VERSION
  s.rubyforge_project = "jimmy_jukebox"
end

