require 'open-uri'
require 'fileutils'
require 'yaml'

module JimmyJukebox

  module SongLoader

    DEFAULT_MUSIC_ROOT_DIR = "~/Music"
    MP3_OGG_REGEXP = /\.mp3$|\.ogg$/i

    def self.original_dixieland_jazz_band(save_dir = DEFAULT_MUSIC_ROOT_DIR + "/JAZZ/Original_Dixieland_Jazz_Band")
      songs = YAML::load_file(File.dirname(__FILE__) + "/songs/OriginalDixielandJazzBand.yml")
      download_songs(songs, save_dir)
    end

    def self.benny_goodman(save_dir = DEFAULT_MUSIC_ROOT_DIR + "/JAZZ/Benny_Goodman")
      songs = YAML::load_file(File.dirname(__FILE__) + "/songs/BennyGoodman.yml")
      download_songs(songs, save_dir)
    end

    def self.lionel_hampton(save_dir = DEFAULT_MUSIC_ROOT_DIR + "/JAZZ/Lionel_Hampton")
      songs = YAML::load_file(File.dirname(__FILE__) + "/songs/LionelHampton.yml")
      download_songs(songs, save_dir)
    end

    def self.charlie_christian(save_dir = DEFAULT_MUSIC_ROOT_DIR + "/JAZZ/Charlie_Christian")
      songs = YAML::load_file(File.dirname(__FILE__) + "/songs/CharlieChristian.yml")
      download_songs(songs, save_dir)
    end

    def self.dizzy_gillespie(save_dir = DEFAULT_MUSIC_ROOT_DIR + "/JAZZ/Dizzy_Gillespie")
      songs = YAML::load_file(File.dirname(__FILE__) + "/songs/DizzyGillespie.yml")
      download_songs(songs, save_dir)
    end

    def self.top_music_dir(save_dir)
      full_path_name = File.expand_path(save_dir)
      home_regexp = /^(\/home\/[^\/]*\/[^\/]*)(\/.*)*$/
      full_path_name = full_path_name.match(home_regexp)[1] if full_path_name =~ home_regexp
      full_path_name
    end

    def self.version_of_song_in_any_dir?(song_filename, save_dir)
      #existing_files =  Dir.chdir(top_music_dir(save_dir)) {
      #  Dir.glob("**/*")
      #}
      existing_files = Dir.glob(File.join(top_music_dir(save_dir), '**', '*' ))
      existing_files.delete_if { |f| !f.match(MP3_OGG_REGEXP) }       # delete unless .mp3, .MP3, .ogg or .OGG
      existing_files.map! { |f| File.basename(f) }    # strip any path info preceding the filename
      existing_files.map! { |f| f.gsub(MP3_OGG_REGEXP,"") }           # strip extensions
      existing_files.include?(song_filename.gsub(MP3_OGG_REGEXP,""))  # does extensionless song_filename exist in directory?
    end

    def self.create_save_dir(save_dir)
      return if File.directory?(save_dir)
      begin
        FileUtils.mkdir_p(save_dir)
      rescue SystemCallError
        puts "WARNING: Unable to create #{save_dir}"
        raise
      end
    end

    private

    def self.download_songs(songs, save_dir)
      save_dir = File.expand_path(save_dir)
      create_save_dir(save_dir) unless File.directory?(save_dir)
      #Dir.chdir(save_dir)
      songs.each do |song_url|
        song_basename = File.basename(song_url)
        next if version_of_song_in_any_dir?(song_basename, save_dir)
        puts "Downloading #{song_basename}"
        open(File.join(save_dir,song_basename), 'wb') do |dst|
          open(song_url) do |src|
            dst.write(src.read)
          end
        end
      end
    end

    def self.version_of_song_in_current_dir?(song_filename)
      existing_files = Dir.entries(".").delete_if { |f| !f.match(MP3_OGG_REGEXP) }  # delete unless .mp3, .MP3, .ogg or .OGG
      existing_files.map! { |f| f.gsub(MP3_OGG_REGEXP,"") }                         # strip extensions
      existing_files.include?(song_filename.gsub(MP3_OGG_REGEXP,"")) ? true : false # does extensionless song_filename exist in directory?
    end

  end

end
