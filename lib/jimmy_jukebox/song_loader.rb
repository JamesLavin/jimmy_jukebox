require 'open-uri'
require 'fileutils'
require 'yaml'

require 'jimmy_jukebox/artists'
include Artists

class Object
  def metaclass
    class << self; self; end
  end
end

require 'jimmy_jukebox/user_config'
include JimmyJukebox

module JimmyJukebox

  module SongLoader

    @user_config = UserConfig.new
    SUPPORTED_MUSIC_TYPES = /\.mp3$|\.ogg$/i

    @last_top_dir = nil            # enables returning previous result if @last_top_dir == top_dir
    @user_config = UserConfig.new

    def self.define_artist(name)
      metaclass.instance_eval do
        define_method(name) do
          save_dir = @user_config.default_music_dir + value_to_subdir_name(name)
          songs = YAML::load_file(File.dirname(__FILE__) + "/songs/#{value_to_yaml_file(name)}")
          download_songs(songs, save_dir)
        end
      end
    end

    JAZZ_ARTISTS.values.each { |v| define_artist v.to_sym }

    def self.top_music_dir(save_dir)
      full_path_name = File.expand_path(save_dir)
      home_regexp = /^(\/home\/[^\/]*\/[^\/]*)(\/.*)*$/
      full_path_name = full_path_name.match(home_regexp)[1] if full_path_name =~ home_regexp
      full_path_name
    end

    def self.version_of_song_in_any_dir?(song_filename, save_dir)
      top_dir = top_music_dir(save_dir)
      @existing_files = calculate_existing_files(top_dir) if top_dir != @last_top_dir  # recalculate existing files only if different top music directory
      @existing_files.include?(song_filename.gsub(SUPPORTED_MUSIC_TYPES,""))                  # does extensionless song_filename exist in directory?
    end

    def self.calculate_existing_files(top_dir)
      #existing_files =  Dir.chdir(top_music_dir(save_dir)) {
      #  Dir.glob("**/*")
      #}
      existing_files = Dir.glob(File.join(top_dir, '**', '*' ))       # all files in all subdirs
      if "".respond_to?(:force_encoding)                                            # Ruby 1.8 doesn't have string encoding or String#force_encoding
        existing_files.delete_if { |f| !f.force_encoding("UTF-8").valid_encoding? } # avoid "invalid byte sequence in UTF-8 (ArgumentError)"
      end
      existing_files.delete_if { |f| !f.match(SUPPORTED_MUSIC_TYPES) }       # delete unless .mp3, .MP3, .ogg or .OGG
      existing_files.map! { |f| File.basename(f) }                    # strip any path info preceding the filename
      existing_files.map! { |f| f.gsub(SUPPORTED_MUSIC_TYPES,"") }           # strip extensions
      @last_top_dir = top_dir
      @existing_files = existing_files
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
        download_song(song_url, save_dir)
      end
    end

    def self.download_song(song_url, save_dir)
      song_savename = File.basename(song_url)
      if version_of_song_in_any_dir?(song_savename, save_dir)
        puts "#{song_savename} already exists in #{save_dir}"
        return
      end
      puts "Downloading #{song_savename}"
      song_pathname = File.join(save_dir,song_savename)
      open(song_pathname, 'wb') do |dst|
        open(song_url) do |src|
          dst.write(src.read)
        end
      end
      check_downloaded_song_size(song_pathname)
    end

    def self.check_downloaded_song_size(song_pathname)
      if !File.exists?(song_pathname)
        puts "Expected to see #{song_pathname} but do not see it!"
        return
      end
      if File.size(song_pathname) < 50000
        puts "Downloaded #{song_pathname} seems too small, so I'm deleting it."
        puts "You might want to try downloading again."
        File.delete(song_pathname)
      end
    end

    def self.version_of_song_in_current_dir?(song_filename)
      existing_files = Dir.entries(".").delete_if { |f| !f.match(SUPPORTED_MUSIC_TYPES) }  # delete unless .mp3, .MP3, .ogg or .OGG
      existing_files.map! { |f| f.gsub(SUPPORTED_MUSIC_TYPES,"") }                         # strip extensions
      existing_files.include?(song_filename.gsub(SUPPORTED_MUSIC_TYPES,"")) ? true : false # does extensionless song_filename exist in directory?
    end

  end

end
