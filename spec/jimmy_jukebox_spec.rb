require 'spec_helper'
require 'fakefs/safe'
require 'jimmy_jukebox'
include JimmyJukebox

# Override exec() to prevent songs from actually playing
# Instead, start a brief sleep process
module Kernel
  alias :real_exec :exec

  def exec(*cmd)
    real_exec("sleep 0.2")  
  end
end

describe Jukebox do

  before(:all) do
    #ARGV.clear
    ARGV.pop
  end

  context "with no command line parameter" do

    it "can be instantiated" do
      jj = Jukebox.new
      jj.should_not be_nil
      jj.quit
    end

    #it "raises exception when no songs available"
    #  lambda do
    #    jj = Jukebox.new
    #  end.should raise_error
    #end

    it "generates a non-empty song list" do
      jj = Jukebox.new
      jj.instance_variable_get(:@user_config).songs.should_not be_nil
      jj.instance_variable_get(:@user_config).songs.should_not be_empty
      jj.instance_variable_get(:@user_config).songs.length.should be > 0
    end

    it "generates a non-empty song list with only mp3 & ogg files" do
      jj = Jukebox.new
      jj.instance_variable_get(:@user_config).songs.each do |song|
        song.should match(/.*\.mp3|.*\.ogg/i)
      end
    end

    it "can play" do
      jj = Jukebox.new
      thread = Thread.new do
        jj.play
      end
      sleep 0.2
      jj.instance_variable_get(:@playing_pid).should_not be_nil
      jj.should_receive(:terminate_current_song)
      jj.quit
    end

    it "can play_loop" do
      jj = Jukebox.new
      thread = Thread.new do
        jj.play_loop
      end
      sleep 0.1
      song1 = jj.playing_pid
      song1.should_not be_nil
      jj.loop.should be_true
      sleep 0.2
      song2 = jj.playing_pid
      song2.should_not be_nil
      song2.should_not == song1
      jj.quit
    end

    it "can skip a song" do
      jj = Jukebox.new
      thread = Thread.new do
        jj.play_loop
      end
      sleep 0.2
      song_1 = jj.playing_pid
      jj.skip_song
      sleep 0.2
      song_2 = jj.playing_pid
      jj.skip_song
      sleep 0.2
      song_3 = jj.playing_pid
      song_1.should_not == song_2 || song_2.should_not == song_3
      jj.quit
    end

    it "can pause the current song" do
      jj = Jukebox.new
      thread = Thread.new do
        jj.play
      end
      sleep 0.1
      song_1 = jj.playing_pid
      jj.pause_current_song
      song_2 = jj.playing_pid
      song_1.should == song_2
      jj.current_song_paused.should be_true
      jj.quit
    end

    it "can unpause a paused song" do
      jj = Jukebox.new
      thread = Thread.new do
        jj.play
      end
      sleep 0.05
      song_1 = jj.playing_pid
      jj.current_song_paused.should be_false
      jj.pause_current_song
      song_2 = jj.playing_pid
      jj.current_song_paused.should be_true
      song_2.should == song_1
      jj.unpause_current_song
      jj.current_song_paused.should be_false
      song_3 = jj.playing_pid
      jj.current_song_paused.should be_false
      jj.pause_current_song
      song_4 = jj.playing_pid
      jj.current_song_paused.should be_true
      song_4.should == song_3
      jj.unpause_current_song
      jj.current_song_paused.should be_false
      jj.quit
    end
  end

  context "with valid music directory as command line parameter" do

    before(:each) do
      ARGV.delete_if { |val| true }
      ARGV << File.expand_path("~/Music")
    end

    it "can skip a song" do
      jj = Jukebox.new
      thread = Thread.new do
        jj.play_loop
      end
      sleep 0.2
      song_1 = jj.playing_pid
      jj.skip_song
      sleep 0.2
      song_2 = jj.playing_pid
      jj.skip_song
      sleep 0.2
      song_3 = jj.playing_pid
      song_1.should_not == song_2 || song_2.should_not == song_3
      jj.quit
    end

  end

end
