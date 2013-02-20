require 'spec_helper'
require 'jimmy_jukebox/song'
require 'jimmy_jukebox/user_config'

include JimmyJukebox

describe Song do

  before(:each) do
  end

  describe "#initialize" do

    it "requires a parameter" do
      expect {Song.new}.to raise_error
    end

    it "fails if parameter does not end in .mp3 or .ogg" do
      expect {Song.new("/home/bill/music_file")}.to raise_error
    end

    it "accepts a parameter ending in .mp3" do
      Song.new("/home/bill/music_file.mp3").is_a?(Song)
    end

    it "accepts a parameter ending in .ogg" do
      Song.new("/home/bill/music_file.ogg").is_a?(Song)
    end

    it "sets a music file" do
      mf = "/home/bill/Music/JAZZ/billie_holiday.ogg"
      song = Song.new(mf)
      song.music_file.should == mf
    end

  end

  describe "#paused?" do

    before(:each) do
      @song = Song.new("~/Music/JAZZ/art_tatum.mp3")
    end

    it "is initially not paused" do
      @song.paused?.should be_false
    end

    it "is paused after calling #pause" do
      @song.pause
      @song.paused?.should be_true
    end

    it "is unpaused after calling #pause and #unpause" do
      @song.pause
      @song.unpause
      @song.paused?.should be_false
    end

  end

  describe "#play" do

    before(:each) do
      @music_file = "~/Music/JAZZ/art_tatum.mp3"
      @song = Song.new(@music_file)
    end

    let(:uc) { double('user_config').as_null_object }
    let(:ps) { double('process_status').as_null_object}

    it "calls #play_with_player" do
      ps.stub(:exitstatus).and_return(0)
      @song.should_receive(:play_with_player).and_return(ps)
      uc.stub(:mp3_player) {"play"}
      uc.stub(:ogg_player) {"play"}
      @song.play(uc)
    end

    it "raises error when exitstatus != 0" do
      ps.stub(:exitstatus).and_return(1)
      @song.should_receive(:play_with_player).and_return(ps)
      uc.stub(:mp3_player) {"play"}
      uc.stub(:ogg_player) {"play"}
      expect{@song.play(uc)}.to raise_error
    end

  end

  describe "#play_with_player" do

    before(:each) do
      @music_file = "~/Music/JAZZ/art_tatum.mp3"
      @song = Song.new(@music_file)
    end

    let(:uc) { double('user_config').as_null_object }
    let(:ps) { double('process_status').as_null_object}

    it "calls #system_yield_pid" do
      uc.stub(:mp3_player) {"play"}
      uc.stub(:ogg_player) {"play"}
      @song.set_player(uc)
      @song.should_receive(:system_yield_pid).with("play",File.expand_path(@music_file)).and_return(ps)
      @song.play_with_player
    end

    it "calls #system_yield_pid and captures playing_pid" do
      pending
      uc.stub(:mp3_player) {"play"}
      uc.stub(:ogg_player) {"play"}
      @song.set_player(uc)
      @song.should_receive(:system_yield_pid).with("play",File.expand_path(@music_file)).and_yield(1469)
      @song.play_with_player
      @song.playing_pid.should == 1469
    end

  end

  describe "#playing_pid" do

    before(:each) do
      @song = Song.new("~/Music/JAZZ/art_tatum.mp3")
    end

    let(:uc) { double('user_config').as_null_object }

    it "is initially nil" do
      @song.playing_pid.should be_nil
    end

    it "is not nil after #play" do
      uc.stub(:mp3_player) {"play"}
      uc.stub(:ogg_player) {"play"}
      thread = Thread.new do
        @song.play(uc)
      end
      sleep 0.1
      @song.playing_pid.should_not be_nil
    end

  end

end
