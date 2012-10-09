require 'spec_helper'
require 'fakefs'
require 'jimmy_jukebox'
include JimmyJukebox

describe Jukebox do

  before(:all) do
    ARGV.clear
  end

  let(:jb) { Jukebox.new }

  let(:uc) { double('user_config').as_null_object }
 
  context "with no command line parameter" do

    it "exists" do
      jb.should_not be_nil
      jb.quit
    end

    it "raises exception when no songs available"
      lambda do
        jb = Jukebox.new
      end.should raise_error
    end

    it "has a user_config method" do
      jb.user_config.is_a?(UserConfig)
    end

    it "has a @user_config instance variable" do
      jb.instance_variable_get(:@user_config).is_a?(UserConfig)
    end

    it "generates a non-empty song list" do
      jb.user_config.songs.should_not be_nil
      jb.user_config.songs.should_not be_empty
      jb.user_config.songs.length.should be > 0
    end

    it "generates a non-empty song list with only mp3 & ogg files" do
      jb.user_config.songs.each do |song|
        song.should match(/.*\.mp3|.*\.ogg/i)
      end
    end

    describe "#play_once" do

      it "should call play_random_song" do
        jb.should_receive(:play_random_song)
        jb.play_once
      end

      it "should have a current_song" do
        uc.stub(:mp3_player) {"play"}
        uc.stub(:ogg_player) {"play"}
        thread = Thread.new do
          jb.play_once
        end
        sleep 0.1
        jb.current_song.is_a?(Song)
        thread.exit
      end

      it "should have a current_song with a music_file" do
        uc.stub(:mp3_player) {"play"}
        uc.stub(:ogg_player) {"play"}
        thread = Thread.new do
          jb.play_once
        end
        sleep 0.1
        jb.current_song.music_file.should match /\.mp3$|\.ogg$/
        thread.exit
      end

      it "should have a player" do
        thread = Thread.new do
          jb.play_once
        end
        sleep 0.1
        jb.current_song.player.should_not be_nil
        thread.exit
      end

      it "should not have a current_song after song finishes" do
        thread = Thread.new do
          jb.play_once
        end
        sleep 0.3
        jb.current_song.should be_nil
        thread.exit
      end

      it "should have a current_song with a playing_pid" do
        thread = Thread.new do
          jb.play_once
        end
        sleep 0.1
        jb.current_song.playing_pid.should_not be_nil
        #jb.should_receive(:terminate_current_song)
        jb.quit
        thread.exit
      end

      it "triggers play_random_song" do
        jb.should_receive(:play_random_song)
        jb.play_once
      end

      it "can pause the current song" do
        thread = Thread.new do
          jb.play_once
        end
        sleep 0.1
        song_1 = jb.current_song.playing_pid
        jb.pause_current_song
        song_2 = jb.current_song.playing_pid
        song_1.should == song_2
        jb.current_song.paused.should be_true
        jb.quit
        thread.exit
      end

      it "can unpause a paused song" do
        thread = Thread.new do
          jb.play_once
        end
        sleep 0.05
        song_1 = jb.current_song
        jb.current_song.paused.should be_false
        jb.pause_current_song
        song_2 = jb.current_song
        jb.current_song.paused.should be_true
        song_2.should == song_1
        jb.unpause_current_song
        jb.current_song.paused.should be_false
        song_3 = jb.current_song
        jb.current_song.paused.should be_false
        jb.pause_current_song
        song_4 = jb.current_song
        jb.current_song.paused.should be_true
        song_4.should == song_3
        jb.unpause_current_song
        jb.current_song.paused.should be_false
        jb.quit
        thread.exit
      end

    end

    describe "#play_loop" do

      it "plays multiple songs" do
        thread = Thread.new do
          jb.play_loop
        end
        sleep 0.1
        song1 = jb.current_song.playing_pid
        song1.should_not be_nil
        jb.continuous_play.should be_true
        sleep 0.2
        song2 = jb.current_song.playing_pid
        song2.should_not be_nil
        song2.should_not == song1
        jb.quit
        thread.exit
      end

      it "can skip a song" do
        thread = Thread.new do
          jb.play_loop
        end
        sleep 0.2
        song_1 = jb.current_song
        jb.skip_song
        sleep 0.2
        song_2 = jb.current_song
        jb.skip_song
        sleep 0.2
        song_3 = jb.current_song
        song_1.should_not == song_2 || song_2.should_not == song_3
        jb.quit
        thread.exit
      end

    end

  end

  context "with valid music directory as command line parameter" do

    before(:each) do
      ARGV.delete_if { |val| true }
      ARGV << File.expand_path("~/Music")
    end

    it "can skip a song" do
      thread = Thread.new do
        jb.play_loop
      end
      sleep 0.2
      song_1 = jb.current_song
      jb.skip_song
      sleep 0.2
      song_2 = jb.current_song
      jb.skip_song
      sleep 0.2
      song_3 = jb.current_song
      song_1.should_not == song_2 || song_2.should_not == song_3
      jb.quit
      thread.exit
    end

  end

end
