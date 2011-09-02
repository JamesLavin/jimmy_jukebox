require 'spec_helper'
require 'fakefs/safe'
require 'jimmy_jukebox'
include JimmyJukebox

describe Jukebox do

  before(:all) do
    ARGV.clear
    #ARGV.pop
  end

  let(:uc) { double('user_config').as_null_object }
 
  context "with no command line parameter" do

    it "exists" do
      Jukebox.should_not be_nil
      Jukebox.quit
    end

    #it "raises exception when no songs available"
    #  lambda do
    #    jj = Jukebox.new
    #  end.should raise_error
    #end

    it "has a user_config method" do
      Jukebox.user_config.is_a?(UserConfig)
    end

    it "has a @user_config instance variable" do
      Jukebox.instance_variable_get(:@user_config).is_a?(UserConfig)
    end

    it "generates a non-empty song list" do
      Jukebox.user_config.songs.should_not be_nil
      Jukebox.user_config.songs.should_not be_empty
      Jukebox.user_config.songs.length.should be > 0
    end

    it "generates a non-empty song list with only mp3 & ogg files" do
      Jukebox.user_config.songs.each do |song|
        song.should match(/.*\.mp3|.*\.ogg/i)
      end
    end

    describe "#play_once" do

      it "should call play_random_song" do
        Jukebox.should_receive(:play_random_song)
        Jukebox.play_once
      end

      it "should have a current_song" do
        jj = Jukebox
        uc.stub(:mp3_player) {"play"}
        uc.stub(:ogg_player) {"play"}
        thread = Thread.new do
          Jukebox.play_once
        end
        sleep 0.1
        jj.current_song.is_a?(Song)
        thread.exit
      end

      it "should have a current_song with a music_file" do
        jj = Jukebox
        uc.stub(:mp3_player) {"play"}
        uc.stub(:ogg_player) {"play"}
        thread = Thread.new do
          Jukebox.play_once
        end
        sleep 0.1
        jj.current_song.music_file.should match /\.mp3$|\.ogg$/
        thread.exit
      end

      it "should have a player" do
        jj = Jukebox
        thread = Thread.new do
          Jukebox.play_once
        end
        sleep 0.1
        jj.current_song.player.should_not be_nil
        thread.exit
      end

      it "should not have a current_song after song finishes" do
        jj = Jukebox
        thread = Thread.new do
          Jukebox.play_once
        end
        sleep 0.3
        jj.current_song.should be_nil
        thread.exit
      end

      it "should have a current_song with a playing_pid" do
        jj = Jukebox
        thread = Thread.new do
          jj.play_once
        end
        sleep 0.1
        jj.current_song.playing_pid.should_not be_nil
        #jj.should_receive(:terminate_current_song)
        jj.quit
        thread.exit
      end

      it "triggers play_random_song" do
        Jukebox.should_receive(:play_random_song)
        Jukebox.play_once
      end

      it "can pause the current song" do
        thread = Thread.new do
          Jukebox.play_once
        end
        sleep 0.1
        song_1 = Jukebox.current_song.playing_pid
        Jukebox.pause_current_song
        song_2 = Jukebox.current_song.playing_pid
        song_1.should == song_2
        Jukebox.current_song.paused.should be_true
        Jukebox.quit
        thread.exit
      end

      it "can unpause a paused song" do
        thread = Thread.new do
          Jukebox.play_once
        end
        sleep 0.05
        song_1 = Jukebox.current_song
        Jukebox.current_song.paused.should be_false
        Jukebox.pause_current_song
        song_2 = Jukebox.current_song
        Jukebox.current_song.paused.should be_true
        song_2.should == song_1
        Jukebox.unpause_current_song
        Jukebox.current_song.paused.should be_false
        song_3 = Jukebox.current_song
        Jukebox.current_song.paused.should be_false
        Jukebox.pause_current_song
        song_4 = Jukebox.current_song
        Jukebox.current_song.paused.should be_true
        song_4.should == song_3
        Jukebox.unpause_current_song
        Jukebox.current_song.paused.should be_false
        Jukebox.quit
        thread.exit
      end

    end

    describe "#play_loop" do

      it "plays multiple songs" do
        thread = Thread.new do
          Jukebox.play_loop
        end
        sleep 0.1
        song1 = Jukebox.current_song.playing_pid
        song1.should_not be_nil
        Jukebox.continuous_play.should be_true
        sleep 0.2
        song2 = Jukebox.current_song.playing_pid
        song2.should_not be_nil
        song2.should_not == song1
        Jukebox.quit
        thread.exit
      end

      it "can skip a song" do
        thread = Thread.new do
          Jukebox.play_loop
        end
        sleep 0.2
        song_1 = Jukebox.current_song
        Jukebox.skip_song
        sleep 0.2
        song_2 = Jukebox.current_song
        Jukebox.skip_song
        sleep 0.2
        song_3 = Jukebox.current_song
        song_1.should_not == song_2 || song_2.should_not == song_3
        Jukebox.quit
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
        Jukebox.play_loop
      end
      sleep 0.2
      song_1 = Jukebox.current_song
      Jukebox.skip_song
      sleep 0.2
      song_2 = Jukebox.current_song
      Jukebox.skip_song
      sleep 0.2
      song_3 = Jukebox.current_song
      song_1.should_not == song_2 || song_2.should_not == song_3
      Jukebox.quit
      thread.exit
    end

  end

end
