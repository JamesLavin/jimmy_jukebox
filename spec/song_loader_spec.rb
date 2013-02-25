require 'spec_helper'
require 'rspec/mocks'
require 'fakeweb' # apparently must be required before fakefs
FakeWeb.allow_net_connect = false
gem 'fakefs', require: 'fakefs/safe'
require 'fakefs/safe'
require 'jimmy_jukebox/song_loader'

describe JimmyJukebox::SongLoader do

  #before(:all) do
    # If using fakefs without safe, make sure we're using FakeFS gem,
    # not the real file system!
    # File.directory?("/home").should be_false
  #end

  before(:each) do
    ARGV.clear
    @sl = JimmyJukebox::SongLoader
  end

  describe "#create_save_dir" do
    include FakeFS::SpecHelpers

    it "should create a directory" do
      topdir = File.join("/home","user_name4","Music")
      subdir = File.join(topdir, "rock", "Beatles")
      File.directory?(subdir).should be_false
      @sl.create_save_dir(subdir)
      File.directory?(subdir).should be_true
    end

  end

  describe "#version_of_song_in_any_dir?" do
    include FakeFS::SpecHelpers

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

    it "should have a user_config" do
      @sl.instance_variable_get(:@user_config).should_not be_nil
    end

    it "should have a user_config with a non-nil default_music_dir" do
      @sl.instance_variable_get(:@user_config).default_music_dir.should == File.expand_path("~/Music")
    end

    it "should have a SUPPORTED_MUSIC_TYPES of '/\.mp3$|\.ogg$/i'" do
      @sl::SUPPORTED_MUSIC_TYPES.should == /\.mp3$|\.ogg$/i
    end

  end

  describe "#original_dixieland_jazz_band without dirname" do
  
    context "no songs in directory" do

      before(:each) do
        @dirname = File.expand_path(@sl.instance_variable_get(:@user_config).default_music_dir + '/JAZZ/Original_Dixieland_Jazz_Band')
        @sl.stub!(:version_of_song_in_any_dir?).and_return(false)
      end

      it "should try to download many songs" do
        @sl.should_receive(:open).at_least(25).times
        @sl.send(:original_dixieland_jazz_band)
      end

    end

  end

  describe "#charlie_christian without dirname" do
   
    context "no songs yet downloaded" do

      it "should try to download many songs" do
        dirname = File.expand_path(@sl.instance_variable_get(:@user_config).default_music_dir + '/JAZZ/Charlie_Christian')
        @sl.stub!(:version_of_song_in_any_dir?).and_return(false)
        @sl.should_receive(:open).exactly(9).times
        @sl.charlie_christian
        File.exists?(dirname).should be_true
      end

    end

    context "all songs already downloaded" do

      it "should not download any songs" do
        dirname = File.expand_path(@sl.instance_variable_get(:@user_config).default_music_dir + '/JAZZ/Charlie_Christian')
        @sl.stub!(:version_of_song_in_any_dir?).and_return(true)
        @sl.should_not_receive(:open)
        @sl.charlie_christian
      end

    end

  end

  describe "#lionel_hampton without dirname" do
    
    it "should try to download many songs" do
      dirname = File.expand_path(@sl.instance_variable_get(:@user_config).default_music_dir + '/JAZZ/Lionel_Hampton')
      @sl.stub!(:version_of_song_in_any_dir?).and_return(false)
      @sl.should_receive(:open).at_least(50).times
      @sl.lionel_hampton
      File.exists?(dirname).should be_true
    end

  end

  describe "#dizzy_gillespie with dirname" do

    it "should try to download three songs" do
      pending "have not yet implemented way to specify artist-specific directory"
      dirname = File.expand_path(@sl.instance_variable_get(:@user_config).default_music_dir + '/JAZZ/Dizzy_Gillespie')
      @sl.stub!(:version_of_song_in_any_dir?).and_return(false)
      @sl.should_receive(:open).exactly(3).times
      @sl.dizzy_gillespie(dirname)
    end

    it "should successfully download three songs" do
      pending "use FakeWeb"
      FakeWeb.register_uri(:any, "http://www.archive.org/download/DizzyGillespie-GroovinHigh/02.GroovinHigh.mp3", :response => "/home/james/Music/JAZZ/Dizzy_Gillespie/Groovin' High 1945.mp3")
      FakeWeb.register_uri(:any, "http://www.archive.org/download/DizzyGillespie-Manteca/01Manteca.ogg", :response => "/home/james/Music/JAZZ/Dizzy_Gillespie/01Manteca.ogg")
      FakeWeb.register_uri(:any, "http://www.archive.org/download/DizzyGillespieLouisArmstrong-UmbrellaMan/DizzyGillespieLouisArmstrong-UmbrellaMan.mp3", :response => "/home/james/Music/JAZZ/Dizzy_Gillespie/DizzyGillespieLouisArmstrong-UmbrellaMan.mp3")
      dirname = File.expand_path("/home/user_name6/non-existent-dir")
      File.exists?(dirname).should be_false
      @sl.dizzy_gillespie(dirname)
      File.exists?(dirname + "/02.GroovinHigh.mp3").should be_true
      File.exists?(dirname + "/01Manteca.ogg").should be_true
      File.exists?(dirname + "/DizzyGillespieLouisArmstrong-UmbrellaMan.mp3").should be_true
      FakeWeb.clean_registry
    end

  end

  describe "call to non-existent method" do

    it "should raise NoMethodError" do
      lambda { @sl.non_existent_method }.should raise_error(NoMethodError)
    end

  end

end
