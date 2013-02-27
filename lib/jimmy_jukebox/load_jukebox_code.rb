lib = File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)
require 'jimmy_jukebox/song_loader'

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

def valid_artist?(arg)
  ARTISTS.has_key?(arg.to_sym)
end

def artist_name(arg)
  ARTISTS[arg.to_sym][:name]
end

def valid_integer?(arg)
  arg && arg.to_i.is_a?(Integer)
end

no_argv0 unless ARGV[0]

invalid_artist unless valid_artist?(ARGV[0])

if valid_integer?(ARGV[1])
  JimmyJukebox::SongLoader.new.send(artist_name(ARGV[0]), ARGV[1].to_i)
else
  JimmyJukebox::SongLoader.new.send(artist_name(ARGV[0]))
end
