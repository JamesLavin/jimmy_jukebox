require 'spec_helper'
require 'fileutils'
require File.dirname(__FILE__) + '/../lib/jimmy_jukebox/user_config'
include JimmyJukebox

describe UserConfig do

  include FakeFS::SpecHelpers

  before(:all) do
    ARGV.clear
  end

  #describe "#configure_preferences" do
  #  context "when configuration file does not exist" do
  #    config_path = File.expand_path(File.join("~",".jimmy_jukebox","configuration"))
  #    FakeFS do
  #      File.exist?(config_path).should be_false
  #    end
  #  end
  #end

  describe "#initialize" do
    let(:user_config) { UserConfig.new }

    describe "blank ARGV" do

      it "uses the default directory" do
        user_config.music_directories.first.should == UserConfig.new.default_music_dir
        user_config.music_directories.length.should == 1
      end

    end

    describe "non-standard dir ARGV" do
      let(:nonstd_dir) { "~/my_music_dir" }

      it "uses the non-standard directory" do
        full_dir = File.expand_path(nonstd_dir)
        FileUtils.mkdir_p(full_dir)
        ARGV[0] = nonstd_dir
        user_config.music_directories.first.should == full_dir
        user_config.music_directories.length.should == 1
        ARGV[0] = nil
      end

    end

    describe "artist dir ARGV" do
      let(:artist_param) { 'jrm' }

      it "uses the artist directory" do
        artist_dir = File.expand_path("~/Music/JAZZ/Jelly_Roll_Morton")
        FileUtils.mkdir_p(artist_dir)
        ARGV[0] = artist_param
        user_config.music_directories.first.should == artist_dir
        user_config.music_directories.length.should == 1
        ARGV[0] = nil
      end

    end

    describe "shortcut 'j' ARGV" do
      let(:shortcut_param) { 'j' }

      it "finds all the jazz directories" do
        at_dir = File.expand_path("~/Music/JAZZ/Art_Tatum")
        de_dir = File.expand_path("~/Music/JAZZ/Duke_Ellington")
        FileUtils.mkdir_p(at_dir)
        FileUtils.mkdir_p(de_dir)
        ARGV[0] = shortcut_param
        user_config.music_directories.should include at_dir
        user_config.music_directories.should include de_dir
        user_config.music_directories.length.should == 3
        ARGV[0] = nil
      end

    end

    describe "(playlist) file as ARGV" do
      let(:dir1) { '~/path2/artist1' }
      let(:dir2) { '~/path3/artist2' }
      let(:d1) { File.expand_path(dir1) }
      let(:d2) { File.expand_path(dir2) }

      before(:each) do
        FileUtils.mkdir_p(d1)
        FileUtils.mkdir_p(d2)
      end

      context "full filepath given" do
        let(:file_param) { '~/path/my_music_dirs.txt' }
        let(:d0) { File.expand_path('~/path') }
      
        it "uses the file's directories" do
          FileUtils.mkdir_p(d0)
          File.open(File.expand_path(file_param), "w") { |f| 
            f.puts dir1
            f.puts dir2
          }
          ARGV[0] = file_param 
          user_config.music_directories.should include d1
          user_config.music_directories.should include d2
          ARGV[0] = nil
        end

      end

      context "only filename given" do
        let(:file_param) { 'my_music_dirs.txt' }
        let(:d0) { File.expand_path('~/.jimmy_jukebox') }
      
        it "uses the file's directories" do
          FileUtils.mkdir_p(d0)
          File.open(File.expand_path(d0 + '/' + file_param), "w") { |f| 
            f.puts dir1
            f.puts dir2
          }
          ARGV[0] = file_param 
          user_config.music_directories.should include d1
          user_config.music_directories.should include d2
          ARGV[0] = nil
        end

      end

    end

  end

  describe "#songs and #undownloaded_songs" do
    let(:user_config) { UserConfig.new }
    let(:dir1) { '~/Music/JAZZ/John_Coltrane' }
    let(:dir2) { '~/Music/CLASSICAL/Vivaldi' }
    let(:d1) { File.expand_path(dir1) }
    let(:d2) { File.expand_path(dir2) }

    before(:each) do
      FileUtils.mkdir_p(d1)
      FileUtils.mkdir_p(d2)
      FileUtils.touch d1 + '/a_love_supreme.mp3'
      FileUtils.touch d1 + '/my_funny_valentine.ogg'
      FileUtils.touch d1 + '/song5.afdsdf'
      FileUtils.touch d2 + '/four_seasons.flac'
      FileUtils.touch d2 + '/spring.wav'
      FileUtils.touch d2 + '/Summer.WAV'
    end

    describe "#songs" do

      it "generates a complete song list" do
        user_config.songs.should include File.expand_path(d1 + '/a_love_supreme.mp3')
        user_config.songs.should include File.expand_path(d1 + '/my_funny_valentine.ogg')
        user_config.songs.should include File.expand_path(d2 + '/four_seasons.flac')
        user_config.songs.should include File.expand_path(d2 + '/spring.wav')
        user_config.songs.should include File.expand_path(d2 + '/Summer.WAV')
        user_config.songs.length.should == 5
      end

      it "does not include the invalid-formatted song in the list" do
        user_config.songs.should_not include File.expand_path(d1 + '/song5.afdsdf')
      end

    end

    describe "#undownloaded_songs" do
   
      before do
        @song_hash = {'http://www.mp3.com/a_love_supreme.mp3' => {:genre => 'JAZZ', :name => 'john_coltrane'},
                      'http://www.flac.net/four_seasons.flac' => {:genre => 'CLASSICAL', :name => 'vivaldi'},
                      'http://www.wav.com/winter.wav' => {:genre => 'CLASSICAL', :name => 'vivaldi'},
                      'http://www.ogg.org/maybeline.ogg' => {:genre => 'ROCK', :name => 'chuck_berry'}
                     }
      end

      it "correctly generates the list of undownloaded songs" do
        JimmyJukebox::SongLoader.any_instance.stub(:all_downloadable_songs).and_return(@song_hash)
        undownloaded_urls = user_config.undownloaded_songs.keys
        undownloaded_urls.should include 'http://www.wav.com/winter.wav'
        undownloaded_urls.should include 'http://www.ogg.org/maybeline.ogg'
        undownloaded_urls.should_not include 'http://www.flac.net/four_seasons.flac'
        undownloaded_urls.should_not include 'http://www.mp3.com/a_love_supreme.mp3'
      end

    end

  end

  describe "#is_a_directory?" do
    it "accepts relative paths" do
      dir = '~/Music/JAZZ/Art_Tatum'
      FileUtils.mkdir_p(File.expand_path(dir))
      UserConfig.new.is_a_directory?(dir).should be_true
    end
  end

  describe "#shortcuts" do

    it "finds dirs based on regex keys" do
      UserConfig.new.shortcuts[/^bluegrass$/i] == UserConfig.new().bluegrass_dir
    end

  end

  describe "#shortcut_to_dir" do
    
    it "knows 'r' means rock-and-roll" do
      UserConfig.new.shortcut_to_dir('r') == UserConfig.new().rock_dir
    end

  end

  describe "#top_music_dir" do

    it "should parse '~/Music'" do
      UserConfig.top_music_dir("~/Music").should == File.expand_path("~/Music")
    end

    it "should parse '/home/xavier/Music'" do
      UserConfig.top_music_dir("/home/xavier/Music").should == "/home/xavier/Music"
    end

    it "should parse '~/Music/Rock/The_Eagles/hotel_california.mp3'" do
      UserConfig.top_music_dir("~/Music/Rock/The_Eagles/hotel_california.mp3").should == File.expand_path("~/Music")
    end

    it "should parse '~/Music/Rock/The Eagles/Hotel California.mp3'" do
      UserConfig.top_music_dir("~/Music/Rock/The Eagles/Hotel California.mp3").should == File.expand_path("~/Music")
    end

    it "should parse '~/My Music'" do
      UserConfig.top_music_dir("~/My Music").should == File.expand_path("~/My Music")
    end

  end
 
  context "with no command line parameter" do

    before(:each) do
      ARGV.delete_if { |val| true }
    end

    let(:uc) { UserConfig.new }

    context "with no songs" do

      it "finds no songs" do
        uc.songs.length.should == 0
      end

    end

    context "with songs in ~/Music" do

      before(:each) do
        FileUtils.mkdir_p File.expand_path("~/Music")
        FileUtils.touch File.expand_path("~/Music/Yellow_Submarine.mp3")
      end

      it "finds songs" do
        uc.songs.should_not be_empty
        uc.songs.length.should == 1
      end

    end

    context "with songs in ~/Music subdirectory" do

      before do
        FileUtils.mkdir_p File.expand_path("~/Music/ROCK/Beatles")
        FileUtils.touch File.expand_path("~/Music/ROCK/Beatles/Yellow_Submarine.mp3")
      end

      it "finds songs" do
        File.directory?(File.expand_path("~/Music/ROCK/Beatles")).should be_true
        uc.songs.should_not be_empty
        uc.songs.length.should == 1
      end

    end

  end

end
