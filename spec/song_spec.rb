require 'spec_helper'
require 'jimmy_jukebox/song'
require 'jimmy_jukebox/user_config'
require 'jimmy_jukebox/jukebox'

include JimmyJukebox

# don't actually play music
module JimmyJukebox
  class Song
    def spawn_method
      if JimmyJukebox::RUNNING_JRUBY
        require 'spoon'
        lambda { |command, arg| Spoon.spawnp('sleep 2') }
      else
        require 'posix/spawn'
        lambda { |command, arg| POSIX::Spawn::spawn('sleep 2') }
      end
    end
  end
end

describe Song do

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
      @uc = UserConfig.new
      @jj = Jukebox.new(@uc, false)
      @song = Song.new("~/Music/JAZZ/art_tatum.mp3")
    end

    it "is initially not paused" do
      @jj.play_song(@song)
      @song.paused?.should be_false
    end

    it "is paused after calling #pause" do
      @jj.play_song(@song)
      @jj.pause_current_song
      @song.paused?.should be_true
    end

    it "is unpaused after calling #pause and #unpause" do
      @jj.play_song(@song)
      @song.pause
      @song.paused?.should be_true
      @song.unpause
      @song.paused?.should be_false
    end

  end

  describe "#skip_song" do

    before(:each) do
      @uc = UserConfig.new
      @jj = Jukebox.new(@uc, false)
      @song = Song.new("~/Music/JAZZ/art_tatum.mp3")
    end

    it "is initially not paused" do
      @jj.play_song(@song)
      @song.playing_pid.should be_kind_of(Integer)
      @jj.skip_song
      @song.playing_pid.should be_nil
    end

  end

  describe "#play_loop" do

    before(:each) do
      @uc = UserConfig.new
      #FileUtils.mkdir_p(File.expand_path("~/Music/JAZZ"))
      @song = Song.new("~/Music/JAZZ/art_tatum.mp3")
      Jukebox.any_instance.stub(:songs).and_return([@song])
      Jukebox.any_instance.stub(:next_song).and_return(@song)
    end

    it "should automatically play the first song" do
      @jj = Jukebox.new(@uc)
      play_loop_thread = Thread.new do
        @jj.play_loop
      end
      sleep 0.1
      @jj.playing?.should be_true
      play_loop_thread.exit
    end
  end

end
