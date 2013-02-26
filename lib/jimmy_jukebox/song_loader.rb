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

    SUPPORTED_MUSIC_TYPES = /\.mp3$|\.ogg$/i

    @user_config = UserConfig.new

    def self.define_artist(name,user_config)
      metaclass.instance_eval do
        define_method(name) do |max_num = nil|
          save_dir = user_config.default_music_dir + artist_name_to_subdir_name(name.to_s)
          songs = YAML::load_file(File.dirname(__FILE__) + "/songs/#{artist_name_to_yaml_file(name.to_s)}")
          download_num_songs(songs, save_dir, max_num)
        end
      end
    end

    ARTISTS.values.each { |artist| define_artist artist[:name].to_sym, @user_config }

    def self.sample(num_songs)
      # create array of all possible songs
      # loop through array and download num_songs new songs (or until end of array reached)
    end

    def self.version_of_song_in_any_dir?(song_filename, save_dir)
      top_dir = UserConfig.top_music_dir(save_dir)
      @existing_files = all_subdir_files(top_dir)
      @existing_files.include?(song_filename.gsub(SUPPORTED_MUSIC_TYPES,""))                  # does extensionless song_filename exist in directory?
    end

    def self.all_subdir_files(dir)
      existing_files = Dir.glob(File.join(dir, '**', '*' ))       # all files in all subdirs
      if "".respond_to?(:force_encoding)                                            # Ruby 1.8 doesn't have string encoding or String#force_encoding
        existing_files.delete_if { |f| !f.force_encoding("UTF-8").valid_encoding? } # avoid "invalid byte sequence in UTF-8 (ArgumentError)"
      end
      existing_files.delete_if { |f| !f.match(SUPPORTED_MUSIC_TYPES) }       # delete unless .mp3, .MP3, .ogg or .OGG
      existing_files.map! { |f| File.basename(f) }                    # strip any path info preceding the filename
      existing_files.map! { |f| f.gsub(SUPPORTED_MUSIC_TYPES,"") }           # strip extensions
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

    def self.get_num_random(songs, num)
      if num && num.kind_of?(Integer)
        songs.shuffle.take(num)
      else
        songs
      end
    end

    def self.download_num_songs(songs, save_dir, max_num = nil)
      songs = get_num_random(songs, max_num) if max_num
      self.download_songs(songs, save_dir)
    end

    def self.download_songs(songs, save_dir)
      save_dir = File.expand_path(save_dir)
      create_save_dir(save_dir) unless File.directory?(save_dir)
      songs.each { |song_url| download_song(song_url, save_dir) }
    end

    def self.song_savename(song_url)
      File.basename(song_url)  
    end

    def self.song_already_exists?(savename, save_dir)
      if version_of_song_in_any_dir?(savename, save_dir)
        puts "#{savename} already exists in #{save_dir}"
        true
      else
        false
      end
    end

    def self.download_song(song_url, save_dir)
      savename = song_savename(song_url)
      return if song_already_exists?(savename, save_dir)
      puts "Downloading #{savename}"
      song_pathname = File.join(save_dir, savename)
      open(song_pathname, 'wb') do |dst|
        open(song_url) do |src|
          dst.write(src.read)
        end
      end
      check_downloaded_song_size(song_pathname)
      rescue OpenURI::HTTPError
        p "Warning: Could not download #{song_url}"
        File.delete(song_pathname) if File.exists?(song_pathname)
        nil
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
