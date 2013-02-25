lib = File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)
require 'jimmy_jukebox/song_loader'
include SongLoader

require 'jimmy_jukebox/artists'
include Artists

def no_argv0
  puts "You must select an artist to use 'load_jukebox'."
  puts "For example: 'load_jukebox at' to load Art Tatum"
  puts "Another example: 'load_jukebox dr' to load Django Reinhardt"
  exit
end

def invalid_artist
  puts "No action taken in response to your command 'load_jukebox #{ARGV[0]}'."
  puts "JimmyJukebox does not recognize '#{ARGV[0]}'. You must select a valid artist."
  puts "For example, valid artists include: 'bh' for Billie Holiday, 'cb' for Count Basie, and 'lh' for Lionel Hampton"
  puts "Please see the README for a complete list of valid artists."
  exit
end

no_argv0 unless ARGV[0]

if ARTISTS.has_key?(ARGV[0].to_sym)
  JimmyJukebox::SongLoader.send(ARTISTS[ARGV[0].to_sym][:name])
else
  invalid_artist
end
