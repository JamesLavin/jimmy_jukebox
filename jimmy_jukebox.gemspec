require 'lib/jimmy_jukebox/version'

spec = Gem::Specification.new do |s|  
  s.name = 'jimmy_jukebox'
  s.author = 'James Lavin'
  s.date = "2011-08-10"
  s.requirements << 'mpg123'
  s.requirements << 'ogg123'
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-core')
  s.add_development_dependency('rspec-mocks')
  s.add_development_dependency('rspec-expectations')
  s.add_development_dependency('fakefs')
  s.add_development_dependency('fakeweb')
  # s.add_dependency
  s.description = 'jimmy_jukebox plays random MP3 & OGG songs under a directory (or set of directories) and can download Dixieland music'
  s.email = 'james@jameslavin.com'
  s.files = Dir['README','roadmap.txt','LICENSE.txt','lib/**/*.rb','lib/**/*.yml','spec/**/*']
  s.homepage = "https://github.com/JamesLavin/jimmy_jukebox"
  s.platform = Gem::Platform::RUBY
  s.require_paths = ['lib']
  s.bindir = 'bin'
  s.executables = ['play_jukebox','load_jukebox']
  s.summary = 'plays MP3 & OGG files in directory (or directories) of your choosing in a random order'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = JimmyJukebox::VERSION
  s.rubyforge_project = "jimmy_jukebox"
end

