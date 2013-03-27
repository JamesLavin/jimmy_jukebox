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
        lambda { |command, arg| Spoon.spawnp('sleep 5') }
      else
        require 'posix/spawn'
        # no idea why ';boguscommand' works, but tests fail without it
        #lambda { |command, arg| POSIX::Spawn::spawn('sleep 2; boguscommand') }
        lambda { |command, arg| POSIX::Spawn::spawn('sleep 5') }
      end
    end
  end
end

describe Song do

  describe "#initialize" do

    it "requires a parameter" do
      expect {Song.new}.to raise_error
    end

    it "fails if parameter does not have file extension" do
      expect {Song.new(File.expand_path("~/music_file"))}.to raise_error
    end

    it "accepts a parameter ending in .mp3" do
      Song.new(File.expand_path("~/music_file.mp3")).is_a?(Song)
    end

    it "accepts a parameter ending in .ogg" do
      Song.new(File.expand_path("~/music_file.ogg")).is_a?(Song)
    end

    it "accepts a parameter ending in .flac" do
      Song.new(File.expand_path("~/music_file.flac")).is_a?(Song)
    end

    it "accepts a parameter ending in .wav" do
      Song.new(File.expand_path("~/music_file.wav")).is_a?(Song)
    end

    it "handles uppercase file extensions" do
      Song.new(File.expand_path("~/music_file.WAV")).is_a?(Song)
    end

    it "sets a music file" do
      mf = "/home/bill/Music/JAZZ/billie_holiday.ogg"
      song = Song.new(mf)
      song.music_file.should == mf
    end

    it "sets a music file when passed with ~" do
      mf = "~/Music/JAZZ/billie_holiday.ogg"
      song = Song.new(mf)
      song.music_file.should == File.expand_path(mf)
    end

  end

  describe "#paused?" do

    before(:each) do
      @uc = UserConfig.new
      @jj = Jukebox.new(@uc, false)
    end

    it "is initially not paused" do
      Thread.new do
        song = Song.new("~/Music/JAZZ/art_tatum.mp3")
        @jj.play_song(song)
      end
      sleep 0.1
      @jj.should be_playing
      @jj.current_song.paused?.should be_false
      @jj.quit
    end

    it "is paused after calling #pause" do
      Thread.new do
        song = Song.new("~/Music/JAZZ/art_tatum.mp3")
        @jj.play_song(song)
      end
      sleep 0.1
      @jj.pause_current_song
      @jj.current_song.paused?.should be_true
      @jj.quit
    end

    it "is unpaused after calling #pause and #unpause" do
      Thread.new do
        song = Song.new("~/Music/JAZZ/art_tatum.mp3")
        @jj.play_song(song)
      end
      sleep 0.1
      @jj.current_song.pause
      @jj.current_song.paused?.should be_true
      @jj.current_song.unpause
      @jj.current_song.paused?.should be_false
      @jj.quit
    end

  end

  describe "#skip_song" do

    before(:each) do
      @uc = UserConfig.new
      @jj = Jukebox.new(@uc, false)
      @jj.stub(:downloaded_song_paths).and_return(['~/Music/JAZZ/Duke_Ellington/song1.ogg','~/Music/CLASSICAL/Bach/song2.mp3'])
      #@song = Song.new("~/Music/JAZZ/art_tatum.mp3")
    end

  end

  describe "#play_loop & #skip_song" do

    before(:each) do
      @uc = UserConfig.new
      @song1 = "~/Music/JAZZ/art_tatum.mp3"
      @song2 = "~/Music/JAZZ/dizzy.mp3"
      @song3 = "~/Music/JAZZ/earl_hines.mp3"
      @song4 = "~/Music/CLASSICAL/beethoven.mp3"
      @jj = Jukebox.new(@uc)
      @jj.stub(:downloaded_song_paths).and_return([@song1, @song2, @song3, @song4])
      @play_loop_thread = Thread.new do
        @jj.play_loop
      end
      sleep 0.1
    end

    describe "#play_loop" do

      it "should automatically play the first song" do
        @jj.should be_playing
        @jj.downloaded_song_paths.map { |f| File.expand_path(f) }.should include @jj.current_song.music_file
        @play_loop_thread.exit
      end

    end

    describe "#skip_song" do

      it "is initially not paused" do
        test_thread = Thread.new do
          @jj.should be_playing
          puts @jj.current_song.playing_pid
          puts @jj.current_song.music_file
          first_song_pid = @jj.current_song.playing_pid
          sleep 0.5
          @jj.skip_song
          puts @jj.current_song.playing_pid
          puts @jj.current_song.music_file
          @jj.current_song.playing_pid.should_not == first_song_pid
          @jj.should be_playing
        end
        [@play_loop_thread, test_thread].each do |t|
          t.join
        end
        @play_loop_thread.exit
      end

    end

  end

end
