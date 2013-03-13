require 'spec_helper'
require File.dirname(__FILE__) + '/../lib/jimmy_jukebox/music_player_detector'
include JimmyJukebox

describe MusicPlayerDetector do

  include FakeFS::SpecHelpers

  let(:detector) { MusicPlayerDetector.new }

  before(:all) do
    ARGV.clear
  end

  describe "#ogg_player" do
  
    it "does not find ogg123 when not present" do
      detector.should_receive(:`).with("which ogg123").and_return("")
      detector.should_receive(:`).with("which music123").and_return("/usr/bin/music123")
      detector.ogg_player.should == 'music123'
    end

    it "finds ogg123 when present" do
      detector.should_receive(:`).with("which ogg123").and_return("/usr/bin/ogg123")
      detector.ogg_player.should == 'ogg123'
    end

    it "finds afplay when present" do
      detector.should_receive(:`).with("which ogg123").and_return("")
      detector.should_receive(:`).with("which music123").and_return("")
      detector.should_receive(:`).with("which afplay").and_return("/usr/bin/afplay")
      detector.ogg_player.should == 'afplay'
    end

    it "finds mplayer when present" do
      detector.should_receive(:`).with("which ogg123").and_return("")
      detector.should_receive(:`).with("which music123").and_return("")
      detector.should_receive(:`).with("which afplay").and_return("")
      detector.should_receive(:`).with("which mplayer").and_return("/usr/bin/mplayer")
      detector.ogg_player.should == 'mplayer -nolirc -noconfig all'
    end

  end

  describe "#mp3_player" do
  
    it "does not find mpg123 when not present" do
      detector.should_receive(:`).with("which mpg123").and_return("")
      detector.should_receive(:`).with("which mpg321").and_return("/usr/bin/mpg321")
      detector.mp3_player.should == 'mpg321'
    end

    it "finds mpg123 when present" do
      detector.should_receive(:`).with("which mpg123").and_return("/usr/bin/mpg123")
      detector.mp3_player.should == 'mpg123'
    end

    it "finds music123 when present" do
      detector.should_receive(:`).with("which mpg123").and_return("")
      detector.should_receive(:`).with("which mpg321").and_return("")
      detector.should_receive(:`).with("which music123").and_return("/usr/bin/music123")
      detector.mp3_player.should == 'music123'
    end

    it "finds mplayer when present" do
      detector.should_receive(:`).with("which mpg123").and_return("")
      detector.should_receive(:`).with("which mpg321").and_return("")
      detector.should_receive(:`).with("which music123").and_return("")
      detector.should_receive(:`).with("which afplay").and_return("")
      detector.should_receive(:`).with("which mplayer").and_return("/usr/bin/mplayer")
      detector.mp3_player.should == 'mplayer -nolirc -noconfig all'
    end

  end

end
