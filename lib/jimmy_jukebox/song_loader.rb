require 'open-uri'
require 'fileutils'
require 'yaml'
require 'uri'

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

  class SongLoader

    MUSIC_TYPES = /\.mp3$|\.ogg$/i

    attr_reader :user_config

    def initialize
      @user_config = UserConfig.new
      ARTISTS.values.each { |artist| define_artist artist[:name].to_sym }
    end

    def define_artist(name)
      metaclass.instance_eval do
        define_method(name) do |max_num = nil|
          save_dir = user_config.default_music_dir + artist_name_to_subdir_name(name.to_s)
          songs = YAML::load_file(File.dirname(__FILE__) + "/songs/#{artist_name_to_yaml_file(name.to_s)}")
          download_num_songs(songs, save_dir, max_num)
        end
      end
    end


    def sample_jazz(num_songs)
      # create array of all possible songs
      # loop through array and download num_songs new songs (or until end of array reached)
      raise "not yet implemented"
    end

    def sample_classical(num_songs)
      raise "not yet implemented"
    end

    def version_of_song_in_dir_or_subdir?(song_filename, save_dir)
      existing_files = all_subdir_music_files_extensionless(save_dir)
      existing_files.include?(song_filename.gsub(SongLoader::MUSIC_TYPES,"")) # does extensionless song_filename exist in directory?
    end

    def version_of_song_under_specific_dir?(song_filename, save_dir)
      existing_files = Dir.entries(".").delete_if { |f| !f.match(SongLoader::MUSIC_TYPES) }  # delete unless .mp3 or .ogg
      existing_files.map! { |f| f.gsub(SongLoader::MUSIC_TYPES,"") }                         # strip extensions
      existing_files.include?(song_filename.gsub(SongLoader::MUSIC_TYPES,"")) ? true : false # does extensionless song_filename exist in directory?
    end

    def all_subdir_music_files(dir)
      existing_files = Dir.glob(File.join(dir, '**', '*' ))   # all files in all subdirs
      if "".respond_to?(:force_encoding)                      # Ruby 1.8 doesn't have string encoding or String#force_encoding
        existing_files.delete_if { |f| !f.force_encoding("UTF-8").valid_encoding? } # avoid "invalid byte sequence in UTF-8 (ArgumentError)"
      end
      existing_files.delete_if { |f| !f.match(SongLoader::MUSIC_TYPES) }  # delete unless .mp3, .MP3, .ogg or .OGG
      existing_files.map { |f| File.basename(f) }                        # strip any path info preceding the filename
    end

    def all_subdir_music_files_extensionless(dir)
      all_subdir_music_files(dir).map! { |f| f.gsub(SongLoader::MUSIC_TYPES,"") }      # strip extensions
    end

    def create_save_dir(save_dir)
      return if File.directory?(save_dir)
      begin
        FileUtils.mkdir_p(save_dir)
      rescue SystemCallError
        puts "WARNING: Unable to create #{save_dir}"
        raise
      end
    end

    def songs_to_filenames(songs)
      songs.map { |song| File.basename(song.music_file) }
    end

    def downloadable(song_urls, current_songs)
      # song_urls are URLs; current_songs are filenames
      song_urls.delete_if { |url| current_songs.include?(File.basename(URI.parse(url).path)) }
    end

    private

    def n_random_songs(songs, num)
      if num && num.kind_of?(Integer)
        songs.shuffle.take(num)
      else
        songs
      end
    end

    def download_num_songs(song_urls, save_dir, max_num = nil)
      current_songs = all_subdir_music_files(save_dir)
      do_not_have = downloadable(song_urls, current_songs)
      p "You already have all songs for this artist" if do_not_have.empty?
      if max_num
        more_songs = max_num - current_songs.length
        if more_songs > 0
          do_not_have = n_random_songs(do_not_have, more_songs)
        else
          p "You already have #{current_songs.length} songs by this artist and are requesting a maximum of #{max_num} songs"
          do_not_have = []
        end
      end
      download_songs(do_not_have, save_dir)
    end

    def download_songs(song_urls, save_dir)
      save_dir = File.expand_path(save_dir)
      create_save_dir(save_dir) unless File.directory?(save_dir)
      song_urls.each { |song_url| download_song(song_url, save_dir) }
    end

    def song_savename(song_url)
      File.basename(song_url)  
    end

    def song_already_exists?(savename, save_dir)
      if version_of_song_in_dir_or_subdir?(savename, save_dir)
        p "#{savename} already exists in #{save_dir}"
        true
      else
        false
      end
    end

    def download_song(song_url, save_dir)
      savename = song_savename(song_url)
      return if song_already_exists?(savename, save_dir)
      p "Downloading #{savename} to #{save_dir}"
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

    def check_downloaded_song_size(song_pathname)
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

  end

end
