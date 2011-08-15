require 'open-uri'
require 'fileutils'
require 'yaml'

class Object
  def metaclass
    class << self; self; end
  end
end

module JimmyJukebox

  module SongLoader

    DEFAULT_MUSIC_ROOT_DIR = "~/Music"
    MP3_OGG_REGEXP = /\.mp3$|\.ogg$/i

    @@last_top_dir = nil   # enables returning previous result if @@last_top_dir == top_dir

    def self.define_artist(name)
      metaclass.instance_eval do
        define_method(name) do
          save_dir = DEFAULT_MUSIC_ROOT_DIR + "/JAZZ/#{name_to_dir_name(name)}"
          songs = YAML::load_file(File.dirname(__FILE__) + "/songs/#{name_to_yaml_file(name)}")
          download_songs(songs, save_dir)
        end
      end
    end

    define_artist :art_tatum
    define_artist :artie_shaw
    define_artist :bennie_moten
    define_artist :benny_goodman
    define_artist :billie_holiday
    define_artist :charlie_christian
    define_artist :count_basie
    define_artist :dizzy_gillespie
    define_artist :django_reinhardt
    define_artist :duke_ellington
    define_artist :fletcher_henderson
    define_artist :jelly_roll_morton
    define_artist :lionel_hampton
    define_artist :louis_armstrong
    define_artist :original_dixieland_jazz_band
    define_artist :red_norvo

    def self.name_to_dir_name(name)
      return name.to_s.capitalize unless name.to_s.grep(/_/)
      name.to_s.split("_").map! { |name_component| name_component.capitalize }.join("_")
    end

    def self.name_to_yaml_file(name)
      return name.to_s.capitalize unless name.to_s.grep(/_/)
      name.to_s.split("_").map! { |name_component| name_component.capitalize }.join("") + '.yml'
    end

    def self.top_music_dir(save_dir)
      full_path_name = File.expand_path(save_dir)
      home_regexp = /^(\/home\/[^\/]*\/[^\/]*)(\/.*)*$/
      full_path_name = full_path_name.match(home_regexp)[1] if full_path_name =~ home_regexp
      full_path_name
    end

    def self.version_of_song_in_any_dir?(song_filename, save_dir)
      top_dir = top_music_dir(save_dir)
      @@existing_files = calculate_existing_files(top_dir) if top_dir != @@last_top_dir  # recalculate existing files only if different top music directory
      @@existing_files.include?(song_filename.gsub(MP3_OGG_REGEXP,""))                   # does extensionless song_filename exist in directory?
    end

    def self.calculate_existing_files(top_dir)
      #existing_files =  Dir.chdir(top_music_dir(save_dir)) {
      #  Dir.glob("**/*")
      #}
      existing_files = Dir.glob(File.join(top_dir, '**', '*' ))       # all files in all subdirs
      existing_files.delete_if { |f| !f.match(MP3_OGG_REGEXP) }       # delete unless .mp3, .MP3, .ogg or .OGG
      existing_files.map! { |f| File.basename(f) }                    # strip any path info preceding the filename
      existing_files.map! { |f| f.gsub(MP3_OGG_REGEXP,"") }           # strip extensions
      @@last_top_dir = top_dir
      @@existing_files = existing_files
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
