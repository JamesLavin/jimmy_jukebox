require File.join(File.dirname(__FILE__), 'lib', 'jimmy_jukebox','version.rb')

spec = Gem::Specification.new do |s|  
  s.name = 'jimmy_jukebox'
  s.author = 'James Lavin'
  s.date = JimmyJukebox::DATE
  s.add_development_dependency('rspec')
  s.add_development_dependency('rspec-core')
  s.add_development_dependency('rspec-mocks')
  s.add_development_dependency('rspec-expectations')
  s.add_development_dependency('fakefs')
  s.add_development_dependency('fakeweb')
  s.description = 'jimmy_jukebox downloads great music and plays random MP3 & OGG songs under a directory (or set of directories)'
  s.email = 'james@jameslavin.com'
  s.files = Dir['README','roadmap.txt','LICENSE.txt','lib/**/*.rb','lib/**/*.yml','spec/**/*']
  s.homepage = "https://github.com/JamesLavin/jimmy_jukebox"
  s.require_paths = ['lib']
  s.bindir = 'bin'
  s.executables = ['play_jukebox','load_jukebox']
  s.summary = 'plays your MP3 & OGG files and lets you easily download music'
  s.test_files = Dir.glob('spec/*.rb')
  s.version = JimmyJukebox::VERSION
  s.rubyforge_project = "jimmy_jukebox"
  s.post_install_message = "I really hope you enjoy the great jazz and classical music downloadable using this gem!"
end

