lib = File.expand_path(File.dirname(__FILE__) + '/..')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)
require 'jimmy_jukebox/song_loader'

require 'jimmy_jukebox/artists'
include Artists

require 'jimmy_jukebox/handle_load_jukebox_input'
include HandleLoadJukeboxInput

no_argv0 unless ARGV[0]

if ARGV[0] =~ /sample/i
  process_sample
elsif radio?(ARGV[0])
  play_radio
elsif valid_artist?(ARGV[0])
  process_artist
else
  invalid_artist
end

