require 'rubygems'
require 'rspec/mocks'
require 'fakeweb' # apparently must be required before fakefs
FakeWeb.allow_net_connect = false
require 'fakefs'
require 'jimmy_jukebox/song_loader'

describe JimmyJukebox::SongLoader do

  before(:all) do
    # make sure we're using FakeFS gem, not real file system!
    File.directory?("/home").should be_false
  end

  before(:each) do
    @sl = JimmyJukebox::SongLoader
  end

  describe "#top_music_dir" do

    it "should parse '~/Music'" do
      @sl.top_music_dir("~/Music").should == "/home/james/Music"
    end

    it "should parse '/home/james/Music'" do
      @sl.top_music_dir("/home/james/Music").should == "/home/james/Music"
    end

    it "should parse '~/Music/Rock/The_Eagles/hotel_california.mp3'" do
      @sl.top_music_dir("~/Music/Rock/The_Eagles/hotel_california.mp3").should == "/home/james/Music"
    end

    it "should parse '~/Music/Rock/The Eagles/Hotel California.mp3'" do
      @sl.top_music_dir("~/Music/Rock/The Eagles/Hotel California.mp3").should == "/home/james/Music"
    end

    it "should parse '~/My Music'" do
      @sl.top_music_dir("~/My Music").should == "/home/james/My Music"
    end

  end

  describe "#create_save_dir" do

    it "should create a directory" do
      topdir = "/home/user_name4/Music"
      subdir = File.join(topdir, "rock", "Beatles")
      File.directory?(subdir).should be_false
      @sl.create_save_dir(subdir)
      File.directory?(subdir).should be_true
    end

  end

  describe "#version_of_song_in_any_dir?" do

    it "should return true if song in top of directory tree" do
      topdir = "/home/user_name1/Music"
      songname = "Paperback_Writer.mp3"
      File.directory?(topdir).should be_false
      FileUtils.mkdir_p(topdir)
      File.directory?(topdir).should be_true
      Dir.chdir(topdir)
      File.exists?(songname).should be_false
      FileUtils.touch(songname)
      File.exists?(songname).should be_true
      @sl.version_of_song_in_any_dir?(songname,topdir).should be_true
    end

    it "should return true if song in subdirectory" do
      topdir = "/home/user_name2/Music"
      subdir = File.join(topdir, "rock", "Beatles")
      songname = "Paperback_Writer.mp3"
      File.directory?(subdir).should be_false
      FileUtils.mkdir_p(subdir)
      FileUtils.touch(File.join(subdir, songname))
      File.exists?(File.join(subdir, songname)).should be_true
      @sl.version_of_song_in_any_dir?(songname,subdir).should be_true
    end

    it "should return false if song not in directory tree" do
      topdir = "/home/user_name3/Music"
      subdir = File.join(topdir, "rock", "Beatles")
      songname = "Paperback_Writer.mp3"
      FileUtils.mkdir_p(subdir)
      File.exists?(File.join(subdir, songname)).should be_false
      @sl.version_of_song_in_any_dir?(songname,subdir).should be_false
    end

  end

  describe "test defaults" do

    it "should have a DEFAULT_MUSIC_ROOT_DIR of '~/Music'" do
      @sl::DEFAULT_MUSIC_ROOT_DIR.should == "~/Music"
    end

    it "should have a MP3_OGG_REGEXP of '/\.mp3$|\.ogg$/i'" do
      @sl::MP3_OGG_REGEXP.should == /\.mp3$|\.ogg$/i
    end

  end

  describe "call to dizzy_gillespie with dirname" do

    it "should try to download three songs" do
      dirname = File.expand_path("/home/user_name5/non-existent-dir")
      File.exists?(dirname).should be_false
      @sl.should_receive(:open).exactly(3).times
      @sl.dizzy_gillespie(dirname)
      File.exists?(dirname).should be_true
    end

    it "should successfully download three songs" do
      pending("use FakeWeb")
      FakeWeb.register_uri(:any, "http://www.archive.org/download/DizzyGillespie-GroovinHigh/02.GroovinHigh.mp3", :response => "/home/james/Music/JAZZ/Dizzy_Gillespie/Groovin' High 1945.mp3")
      FakeWeb.register_uri(:any, "http://www.archive.org/download/DizzyGillespie-Manteca/01Manteca.ogg", :response => "/home/james/Music/JAZZ/Dizzy_Gillespie/01Manteca.ogg")
      FakeWeb.register_uri(:any, "http://www.archive.org/download/DizzyGillespieLouisArmstrong-UmbrellaMan/DizzyGillespieLouisArmstrong-UmbrellaMan.mp3", :response => "/home/james/Music/JAZZ/Dizzy_Gillespie/DizzyGillespieLouisArmstrong-UmbrellaMan.mp3")
      dirname = File.expand_path("/home/user_name6/non-existent-dir")
      File.exists?(dirname).should be_false
      @sl.dizzy_gillespie(dirname)
      #File.exists?(dirname + "/02.GroovinHigh.mp3").should be_true
      #File.exists?(dirname + "/01Manteca.ogg").should be_true
      #File.exists?(dirname + "/DizzyGillespieLouisArmstrong-UmbrellaMan.mp3").should be_true
      FakeWeb.clean_registry
    end

  end

  describe "call to non-existent method" do

    it "should raise NoMethodError" do
      lambda { @sl.non_existent_method }.should raise_error(NoMethodError)
    end

  end

end
