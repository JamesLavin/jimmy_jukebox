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
      Thread.new do
        @jj.play_song(@song)
      end
      sleep 0.1
      @song.paused?.should be_false
      @jj.quit
    end

    it "is paused after calling #pause" do
      Thread.new do
        @jj.play_song(@song)
      end
      sleep 0.1
      @jj.pause_current_song
      @song.paused?.should be_true
      @jj.quit
    end

    it "is unpaused after calling #pause and #unpause" do
      Thread.new do
        @jj.play_song(@song)
      end
      sleep 0.1
      @song.pause
      @song.paused?.should be_true
      @song.unpause
      @song.paused?.should be_false
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
      #FileUtils.mkdir_p(File.expand_path("~/Music/JAZZ"))
      @song1 = "~/Music/JAZZ/art_tatum.mp3"
      @song2 = "~/Music/JAZZ/dizzy.mp3"
      @song3 = "~/Music/JAZZ/earl_hines.mp3"
      @song4 = "~/Music/CLASSICAL/beethoven.mp3"
      #Jukebox.any_instance.stub(:downloaded_song_paths).and_return([@song, @song2])
      #Jukebox.any_instance.stub(:next_song).and_return(@song2)
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
        @jj.should be_playing
        puts @jj.current_song.playing_pid
        puts @jj.current_song.music_file
        first_song_pid = @jj.current_song.playing_pid
        thread2 = Thread.new do
          loop do
            sleep 0.5
            @jj.skip_song
          end
        end
        [@play_loop_thread, thread2].each do |t|
          t.join
        end
        puts @jj.current_song.playing_pid
        puts @jj.current_song.music_file
        @jj.current_song.playing_pid.should_not == first_song_pid
        @jj.should be_playing
        @play_loop_thread.exit
      end

    end

  end

end
