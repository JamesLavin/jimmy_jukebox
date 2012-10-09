require 'spec_helper'
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

  #describe "#set_default_mp3_dir" do
  #
  #
  #end

  describe "#top_music_dir" do

    it "should parse '~/Music'" do
      UserConfig.top_music_dir("~/Music").should == "/home/xavier/Music"
    end

    it "should parse '/home/xavier/Music'" do
      UserConfig.top_music_dir("/home/xavier/Music").should == "/home/xavier/Music"
    end

    it "should parse '~/Music/Rock/The_Eagles/hotel_california.mp3'" do
      UserConfig.top_music_dir("~/Music/Rock/The_Eagles/hotel_california.mp3").should == "/home/xavier/Music"
    end

    it "should parse '~/Music/Rock/The Eagles/Hotel California.mp3'" do
      UserConfig.top_music_dir("~/Music/Rock/The Eagles/Hotel California.mp3").should == "/home/xavier/Music"
    end

    it "should parse '~/My Music'" do
      UserConfig.top_music_dir("~/My Music").should == "/home/xavier/My Music"
    end

  end
 
  context "with no command line parameter" do

    before(:each) do
      ARGV.delete_if { |val| true }
    end

    let(:uc) { UserConfig.new }

    it "does not complain when ogg123 & mpg123 both installed" do
      uc.should_receive(:`).with("which ogg123").and_return("/usr/bin/ogg123")
      uc.should_receive(:`).with("which mpg123").and_return("/usr/bin/mpg123")
      uc.should_not_receive(:puts)
      uc.send(:set_music_players)
      uc.instance_variable_get(:@ogg_player).should == "ogg123"
      uc.instance_variable_get(:@mp3_player).should == "mpg123"
    end

    it "does not complain when ogg123 & mpg321 both installed but not mpg123" do
      uc.should_receive(:`).with("which ogg123").and_return("/usr/bin/ogg123")
      uc.should_receive(:`).with("which mpg123").and_return("")
      uc.should_receive(:`).with("which mpg321").and_return("/usr/bin/mpg321")
      uc.should_not_receive(:puts)
      uc.send(:set_music_players)
      uc.instance_variable_get(:@ogg_player).should == "ogg123"
      uc.instance_variable_get(:@mp3_player).should == "mpg321"
    end

    it "complains when ogg123 installed but mpg123, mpg321, music123, afplay & play not installed" do
      uc.instance_variable_set(:@ogg_player, nil)
      uc.instance_variable_set(:@mp3_player, nil)
      uc.should_receive(:`).at_least(:once).with("which ogg123").and_return("/usr/bin/ogg123")
      uc.should_receive(:`).at_least(:once).with("which mpg123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mpg321").and_return("")
      uc.should_receive(:`).at_least(:once).with("which music123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      uc.should_receive(:`).at_least(:once).with("which play").and_return("")
      uc.should_receive(:puts).with("*** YOU CANNOT PLAY MP3S -- YOU MIGHT WANT TO INSTALL MPG123 OR MPG321 ***")
      uc.send(:set_music_players)
      uc.instance_variable_get(:@ogg_player).should == "ogg123"
      uc.instance_variable_get(:@mp3_player).should be_false
    end

    it "complains when mpg123 installed but ogg123, mpg321, music123, afplay & play not installed" do
      uc.instance_variable_set(:@ogg_player, nil)
      uc.instance_variable_set(:@mp3_player, nil)
      uc.should_receive(:`).at_least(:once).with("which ogg123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which music123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mpg123").and_return("/usr/bin/mpg123")
      uc.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      uc.should_receive(:`).at_least(:once).with("which play").and_return("")
      uc.should_receive(:puts).with("*** YOU CANNOT PLAY OGG FILES -- YOU MIGHT WANT TO INSTALL OGG123 ***")
      uc.send(:set_music_players)
      uc.instance_variable_get(:@ogg_player).should be_false
      uc.instance_variable_get(:@mp3_player).should == "mpg123"
    end

    it "complains when mpg321 installed but mpg123, music123, ogg123, afplay & play not installed" do
      uc.instance_variable_set(:@ogg_player, nil)
      uc.instance_variable_set(:@mp3_player, nil)
      uc.should_receive(:`).at_least(:once).with("which ogg123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mpg123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which music123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mpg321").and_return("/usr/bin/mpg321")
      uc.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      uc.should_receive(:`).at_least(:once).with("which play").and_return("")
      uc.should_receive(:puts).with("*** YOU CANNOT PLAY OGG FILES -- YOU MIGHT WANT TO INSTALL OGG123 ***")
      uc.send(:set_music_players)
      uc.instance_variable_get(:@ogg_player).should be_false
      uc.instance_variable_get(:@mp3_player).should == "mpg321"
    end

    it "prints message and exits when mpg123, mpg321, ogg123, music123, afplay & play all not installed" do
      uc.instance_variable_set(:@ogg_player, nil)
      uc.instance_variable_set(:@mp3_player, nil)
      uc.should_receive(:`).at_least(:once).with("which ogg123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mpg123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which music123").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mpg321").and_return("")
      uc.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      uc.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      uc.should_receive(:`).at_least(:once).with("which play").and_return("")
      error_msg = "*** YOU CANNOT PLAY MP3S OR OGG FILES -- YOU MIGHT WANT TO INSTALL ogg123 AND mpg123/mpg321 BEFORE USING JIMMYJUKEBOX ***"
      uc.should_receive(:puts).with(error_msg)
      lambda { uc.send(:set_music_players) }.should raise_error SystemExit
    end

  end

end

