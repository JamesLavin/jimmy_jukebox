require 'open-uri'
require 'fileutils'
require 'yaml'
require 'uri'

require 'jimmy_jukebox/constants'
require 'jimmy_jukebox/artists'
include Artists

class Object
  def metaclass
    class << self; self; end
  end
end

class Hash
  def rand_key
    keys.at(Random.new.rand(0..(keys.size - 1)))
  end

  def rand_pair
    k = rand_key
    return k, fetch(k)
  end

  def rand_pair!
    k,v = rand_pair
    delete( k )
    return k,v
  end
end

require 'jimmy_jukebox/user_config'
include JimmyJukebox

require 'jimmy_jukebox/song'

module JimmyJukebox

  class SongLoader

    attr_reader :user_config

    def initialize
      @user_config = UserConfig.new
      ARTISTS.values.each { |artist| define_artist artist[:name].to_sym }
    end

    def define_artist(name)
      metaclass.instance_eval do
        define_method(name) do |max_num = nil|
          save_dir = user_config.root_music_dir + artist_name_to_subdir_name(name.to_s)
          songs = YAML::load_file(File.dirname(__FILE__) + "/songs/#{artist_name_to_yaml_file(name.to_s)}")
          download_num_songs(songs, save_dir, max_num)
        end
      end
    end

    def all_songs(genre = nil) # valid genres: 'JAZZ', 'CLASSICAL', 'BLUEGRASS', 'BANJO', 'ROCK'
      all_songs = {}
      ARTISTS.values.each do |artist|
        next if genre && artist[:genre] != genre
        fn = File.dirname(__FILE__) + "/songs/#{artist_name_to_yaml_file(artist[:name].to_s)}"
        if File.exists?(fn)
          YAML::load_file(fn).each do |song|
            all_songs[song] = artist
          end
        end
      end
      all_songs
    end

    def sample_genre(num_songs, genre = nil)
      # loop through array and download num_songs new songs (or until end of array reached)
      sample = {}
      available_songs = all_songs(genre)
      num_songs.times do
        unless available_songs.length == 0
          k, v = available_songs.rand_pair!
          sample[k] = v
        end
      end
      sample
    end

    def download_sample_genre(num_songs = 1, genre = nil)
      sample = sample_genre(num_songs, genre)
      sample.each do |song_url, artist|
        save_dir = user_config.root_music_dir + artist_name_to_subdir_name(artist[:name].to_s)
        download_song(song_url, save_dir)
      end
    end

    def sample_classical(num_songs)
      raise "not yet implemented"
    end

    def valid_music_format_extension?(song_filename)
      JimmyJukebox::AUDIO_FORMATS.keys.any? { |k|
        song_filename =~ k
      }
    end

    def strip_music_format_extension(song_filename)
      fn = song_filename.dup
      JimmyJukebox::AUDIO_FORMATS.keys.each do |k|
        fn.gsub!(k,"") if fn =~ k
      end
      fn
    end

    def version_of_song_in_dir_or_subdir?(song_filename, save_dir)
      extensionless_song_filename = strip_music_format_extension(song_filename)
      existing_files = all_subdir_music_files_extensionless(save_dir)
      existing_files.include?(extensionless_song_filename) # does extensionless song_filename exist in directory?
    end

    def version_of_song_under_specific_dir?(song_filename, save_dir)
      extensionless_song_filename = strip_music_format_extension(song_filename)
      existing_files = Dir.entries(".").delete_if { |f| !valid_music_format_extension?(f) }  # delete unless valid format
      existing_files.map! { |f| strip_music_format_extension(f) }  # strip extensions
      existing_files.include?(extensionless_song_filename) # does extensionless song_filename exist in directory?
    end

    def all_subdir_music_files(dir)
      existing_files = Dir.glob(File.join(dir, '**', '*' ))   # all files in all subdirs
      if "".respond_to?(:force_encoding)                      # Ruby 1.8 doesn't have string encoding or String#force_encoding
        existing_files.delete_if { |f| !f.force_encoding("UTF-8").valid_encoding? } # avoid "invalid byte sequence in UTF-8 (ArgumentError)"
      end
      existing_files.delete_if { |f| !valid_music_format_extension?(f) }  # delete unless valid format
      existing_files.map { |f| File.basename(f) }                        # strip any path info preceding the filename
    end

    def all_subdir_music_files_extensionless(dir)
      all_subdir_music_files(dir).map! { |f| strip_music_format_extension(f) }      # strip extensions
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
      puts "You already have all #{current_songs.length} songs for this artist" if do_not_have.empty?
      if max_num
        more_songs = max_num - current_songs.length
        if more_songs > 0
          do_not_have = n_random_songs(do_not_have, more_songs)
        else
          puts "You already have #{current_songs.length} songs by this artist and are requesting a maximum of #{max_num} songs"
          return nil
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
        puts "#{savename} already exists in #{save_dir}"
        true
      else
        false
      end
    end

    def download_song(song_url, save_dir)
      create_save_dir(save_dir) unless File.directory?(save_dir)
      savename = song_savename(song_url)
      return if song_already_exists?(savename, save_dir)
      puts "Downloading #{savename} to #{save_dir}"
      song_pathname = File.join(save_dir, savename)
      open(song_pathname, 'wb') do |dst|
        open(song_url) do |src|
          dst.write(src.read)
        end
      end
      check_downloaded_song_size(song_pathname)
      rescue OpenURI::HTTPError
        puts "Warning: Could not download #{song_url}"
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
