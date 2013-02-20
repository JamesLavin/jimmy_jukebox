require 'spec_helper'
require_relative '../lib/jimmy_jukebox/jukebox'
include JimmyJukebox

describe Jukebox do

  include FakeFS::SpecHelpers

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

    it "calls play_random_song" do
      jb.stub(:play_random_song).and_return(nil)
      jb.should_receive(:play_once)
      jb.play_once
      jb.quit
    end

    it "raises exception when no songs available" do
      expect { jb.play_once }.to raise_error(Jukebox::NoSongException)
    end

    it "has a user_config method" do
      jb.user_config.is_a?(UserConfig)
    end

    it "generates an empty song list" do
      jb.user_config.songs.should be_empty
      jb.user_config.songs.length.should == 0
    end

    context "when songs exist" do

      let(:song1) { '/home/xavier/Music/Rock/Beatles/Abbey_Road.mp3' }
      let(:song2) { '/home/xavier/Music/Rock/Beatles/Sgt_Pepper.mp3' }
      let(:song3) { '/home/xavier/Music/Rock/Eagles/Hotel_California.ogg' }

      before do
        [song1, song2, song3].each do |song|
          FileUtils.mkdir_p(File.dirname(song))
          FileUtils.touch(song)
          Dir.chdir('/home/xavier')
        end
      end

      it "generates a non-empty song list" do
        jb.user_config.songs.should_not be_nil
        jb.user_config.songs.should_not be_empty
        jb.user_config.songs.length.should == 3
        jb.user_config.songs.should include(/Abbey_Road.mp3/)
      end

=begin
      xit "generates a non-empty song list with only mp3 & ogg files" do
        jb.user_config.songs.each do |song|
          song.should match(/.*\.mp3|.*\.ogg/i)
        end
      end

      describe "#play_once" do

        xit "should call play_random_song" do
          jb.should_receive(:play_random_song)
          jb.play_once
        end

        xit "should have a current_song" do
          uc.stub(:mp3_player) {"play"}
          uc.stub(:ogg_player) {"play"}
          thread = Thread.new do
            jb.play_once
          end
          sleep 0.1
          jb.current_song.is_a?(Song)
          thread.exit
        end

        xit "should have a current_song with a music_file" do
          uc.stub(:mp3_player) {"play"}
          uc.stub(:ogg_player) {"play"}
          thread = Thread.new do
            jb.play_once
          end
          sleep 0.1
          jb.current_song.music_file.should match /\.mp3$|\.ogg$/
          thread.exit
        xend

        xit "should have a player" do
          thread = Thread.new do
            jb.play_once
          end
          sleep 0.1
          jb.current_song.player.should_not be_nil
          thread.exit
        end

        xit "should not have a current_song after song finishes" do
          thread = Thread.new do
            jb.play_once
          end
          sleep 0.3
          jb.current_song.should be_nil
          thread.exit
        end

        xit "should have a current_song with a playing_pid" do
          thread = Thread.new do
            jb.play_once
          end
          sleep 0.1
          jb.current_song.playing_pid.should_not be_nil
          #jb.should_receive(:terminate_current_song)
          jb.quit
          thread.exit
        end

        xit "triggers play_random_song" do
          jb.should_receive(:play_random_song)
          jb.play_once
        end

        xit "can pause the current song" do
          thread = Thread.new do
            jb.play_once
          end
          sleep 0.1
          song_1 = jb.current_song.playing_pid
          jb.pause_current_song
          song_2 = jb.current_song.playing_pid
          song_1.should == song_2
          jb.current_song.paused?.should be_true
          jb.quit
          thread.exit
        end

        xit "can unpause a paused song" do
          thread = Thread.new do
            jb.play_once
          end
          sleep 0.05
          song_1 = jb.current_song
          jb.current_song.paused?.should be_false
          jb.pause_current_song
          song_2 = jb.current_song
          jb.current_song.paused?.should be_true
          song_2.should == song_1
          jb.unpause_current_song
          jb.current_song.paused?.should be_false
          song_3 = jb.current_song
          jb.current_song.paused?.should be_false
          jb.pause_current_song
          song_4 = jb.current_song
          jb.current_song.paused?.should be_true
          song_4.should == song_3
          jb.unpause_current_song
          jb.current_song.paused?.should be_false
          jb.quit
          thread.exit
        end

=end
    end

  end
=begin
    describe "#play_loop" do

      xit "plays multiple songs" do
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

      xit "can skip a song" do
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

    xit "can skip a song" do
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

=end

end
