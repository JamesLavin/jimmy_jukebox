require 'fileutils'

require 'jimmy_jukebox/artists'
include Artists

module JimmyJukebox

  def self.running_x_windows
    xset_location = `which xset`
    if xset_location
      !!xset_location.match(/\/xset/)
    else
      false
    end
  end

  RUNNING_JRUBY = defined?(JRUBY_VERSION) || (defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby') || RUBY_PLATFORM == 'java'
  RUNNING_LINUX = RbConfig::CONFIG['host_os'] =~ /linux/i
  RUNNING_X_WINDOWS = running_x_windows

  class UserConfig

    attr_writer   :music_directories
    attr_accessor :songs, :ogg_player, :mp3_player

    DEFAULT_PLAYLIST_DIR = File.expand_path(File.join("~",".jimmy_jukebox"))

    def self.top_music_dir(save_dir)
      full_path_name = File.expand_path(save_dir)
      home_regexp = /^(\/home\/[^\/]*\/[^\/]*)(\/.*)*$/
      full_path_name = full_path_name.match(home_regexp)[1] if full_path_name =~ home_regexp
      full_path_name
    end

    def initialize
      self.songs = []
      set_music_players
      generate_directories_list
      generate_song_list
    end

    def shortcuts
      { /^b$/i         => bluegrass_dir,
        /^bluegrass$/i => bluegrass_dir,
        /^c$/i         => classical_dir,
        /^classical$/i => classical_dir,
        /^j$/i         => jazz_dir,
        /^jazz$/i      => jazz_dir,
        /^r$/i         => rock_dir,
        /^rock$/i      => rock_dir }
    end

    def default_music_dir
      File.expand_path(File.join("~","Music"))
    end

    def bluegrass_dir
      default_music_dir + '/BLUEGRASS'
    end

    def jazz_dir
      default_music_dir + '/JAZZ'
    end

    def rock_dir
      default_music_dir + '/ROCK'
    end

    def classical_dir
      default_music_dir + '/CLASSICAL'
    end

    def set_music_players
      set_ogg_player
      set_mp3_player
      no_player_configured unless ogg_player || mp3_player
      warn_about_partial_functionality if !ogg_player || !mp3_player
    end

    def no_player_configured
      puts "*** YOU CANNOT PLAY MP3S OR OGG FILES -- YOU MIGHT WANT TO INSTALL ogg123 AND mpg123/mpg321 BEFORE USING JIMMYJUKEBOX ***"
      exit
    end

    def warn_about_partial_functionality
      if ogg_player && !mp3_player
        puts "*** YOU CANNOT PLAY MP3S -- YOU MIGHT WANT TO INSTALL MPG123 OR MPG321 ***"
      elsif mp3_player && !ogg_player
        puts "*** YOU CANNOT PLAY OGG FILES -- YOU MIGHT WANT TO INSTALL OGG123 ***"
      end
    end

    def set_ogg_player
      if ogg123_exists?
        self.ogg_player = "ogg123"
        return
      elsif music123_exists?
        self.ogg_player = "music123"
        return
      elsif afplay_exists?
        self.ogg_player = "afplay"
        return
      elsif mplayer_exists?
        self.ogg_player = "mplayer -nolirc -noconfig all"
      elsif play_exists?
        self.ogg_player = "play"
      end
    end

    def set_mp3_player
      if mpg123_exists?
        self.mp3_player = "mpg123"
        return
      elsif mpg321_exists?
        self.mp3_player = "mpg321"
        return
      elsif music123_exists?
        self.mp3_player = "music123"
        return
      elsif afplay_exists?
        self.mp3_player = "afplay"
        return
      elsif mplayer_exists?
        self.mp3_player = "mplayer -nolirc -noconfig all"
      elsif play_exists?
        self.mp3_player = "play"
      end
    end

    def ogg123_exists?
      `which ogg123`.match(/.*\/ogg123$/) ? true : false
    end

    def mpg123_exists?
      `which mpg123`.match(/.*\/mpg123$/) ? true : false
    end

    def music123_exists?
      `which music123`.match(/.*\/music123$/) ? true : false
    end

    def mpg321_exists?
      `which mpg321`.match(/.*\/mpg321$/) ? true : false
    end

    def afplay_exists?
      `which afplay`.match(/.*\/afplay$/) ? true : false
    end

    def mplayer_exists?
      `which mplayer`.match(/.*\/mplayer$/) ? true : false
    end

    def play_exists?
      `which play`.match(/.*\/play$/) ? true : false
    end

    def set_music_directories_from_file
      if File.exists?(File.expand_path(ARGV[0]))
        @music_directories_file = File.expand_path(ARGV[0])
      elsif File.exists?( File.expand_path( File.join(DEFAULT_PLAYLIST_DIR, ARGV[0]) ) )
        @music_directories_file = File.expand_path(File.join(DEFAULT_PLAYLIST_DIR, ARGV[0]))
      end
      load_top_level_directories_from_file
    end

    def music_directories
      @music_directories ||= []
    end

    def shortcut_to_dir(user_input)
      reg_ex = shortcuts.keys.detect { |re| re =~ user_input }
      reg_ex ? shortcuts[reg_ex] : nil
    end

    def generate_directories_list
      # ARGV[0] can be "jazz.txt" (a file holding directory names),
      # a shortcut (like 'j' or 'jazz' for jazz or 'r' or 'rock' for rock),
      # an artist shortcut (like 'bg' for Benny Goodman or 'md' for Miles Davis),
      # a directory path (like "~/Music/JAZZ")
      # or nil
      if ARGV.empty?
        music_directories << default_music_dir
      elsif dir = shortcut_to_dir(ARGV[0].strip)
        music_directories << dir
      elsif ARTISTS.keys.include?(ARGV[0].to_sym)
        music_directories << default_music_dir + artist_key_to_subdir_name(ARGV[0].to_sym)
      elsif is_a_txt_file?(ARGV[0])
        set_music_directories_from_file
      elsif is_a_directory?(ARGV[0])
        music_directories << File.expand_path(ARGV[0])
      else
        music_directories << default_music_dir
      end
      create_nonexistent_music_directories
      add_all_subdirectories
    end

    def create_nonexistent_music_directories
      music_directories.each do |md|
        FileUtils.mkdir_p(md) unless Dir.exists?(md)
      end
    end

    def is_a_txt_file?(whatever)
      return false unless whatever
      whatever.match(/.*\.txt/) ? true : false
    end

    def is_a_directory?(whatever)
      return false unless whatever
      File.directory?(File.expand_path(whatever)) ? true : false
    end

    def load_top_level_directories_from_file
      File.open(@music_directories_file, "r") do |inf|
        while (line = inf.gets)
          line.strip!
          music_directories << File.expand_path(line)
        end
      end
    end

    def all_subdirectories(dir)
      Dir.glob(File.join(dir,"**/","*/"))
         .delete_if {|dir_name| !File.directory?(dir_name)}
         .map { |dir_name| File.expand_path(dir_name) }
    end

    def add_all_subdirectories
      new_dirs = []
      music_directories.each do |dir|
        new_dirs = new_dirs + all_subdirectories(dir)
      end
      self.music_directories = music_directories + new_dirs
    end

    def generate_song_list
      music_directories.each do |music_dir|
        files = Dir.entries(File.expand_path(music_dir))
        if "".respond_to?(:force_encoding)                                  # Ruby 1.8 doesn't have string encoding or String#force_encoding
         files.delete_if { |f| !f.force_encoding("UTF-8").valid_encoding? } # avoid "invalid byte sequence in UTF-8 (ArgumentError)"
        end
        files.delete_if { |f| !f.match(/.*\.mp3/i) && !f.match(/.*\.ogg/i) }
        files.map! { |f| File.expand_path(music_dir) + '/' + f }
        files.each { |f| songs << f }
      end
      puts "WARNING: JimmyJukebox could not find any songs" unless songs.length > 0
      #songs = ["~/Music/Artie_Shaw/Georgia On My Mind 1941.mp3",
      #         "~/Music/Jelly_Roll_Morton/High Society 1939.mp3"]
    end

  end

end 
