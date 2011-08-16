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

  context "with no command line parameter" do

    before(:each) do
      ARGV.delete_if { |val| true }
    end

    it "can be instantiated" do
      jj = Jukebox.new
      jj.should_not be_nil
      jj.quit
    end

    it "does not complain when ogg123 & mpg123 both installed" do
      jj = Jukebox.new
      jj.should_receive(:`).with("which ogg123").and_return("/usr/bin/ogg123")
      jj.should_receive(:`).with("which mpg123").and_return("/usr/bin/mpg123")
      jj.should_not_receive(:puts)
      jj.send(:set_music_players)
      jj.instance_variable_get(:@ogg_player).should == "ogg123"
      jj.instance_variable_get(:@mp3_player).should == "mpg123"
      jj.quit
    end

    it "does not complain when ogg123 & mpg321 both installed but not mpg123" do
      jj = Jukebox.new
      jj.should_receive(:`).with("which ogg123").and_return("/usr/bin/ogg123")
      jj.should_receive(:`).with("which mpg123").and_return("")
      jj.should_receive(:`).with("which mpg321").and_return("/usr/bin/mpg321")
      jj.should_not_receive(:puts)
      jj.send(:set_music_players)
      jj.instance_variable_get(:@ogg_player).should == "ogg123"
      jj.instance_variable_get(:@mp3_player).should == "mpg321"
      jj.quit
    end

    it "complains when ogg123 installed but mpg123, mpg321, music123, afplay & play not installed" do
      jj = Jukebox.new
      jj.instance_variable_set(:@ogg_player, nil)
      jj.instance_variable_set(:@mp3_player, nil)
      jj.should_receive(:`).at_least(:once).with("which ogg123").and_return("/usr/bin/ogg123")
      jj.should_receive(:`).at_least(:once).with("which mpg123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mpg321").and_return("")
      jj.should_receive(:`).at_least(:once).with("which music123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      jj.should_receive(:`).at_least(:once).with("which play").and_return("")
      jj.should_receive(:puts).with("*** YOU CANNOT PLAY MP3S -- YOU MIGHT WANT TO INSTALL MPG123 OR MPG321 ***")
      jj.send(:set_music_players)
      jj.instance_variable_get(:@ogg_player).should == "ogg123"
      jj.instance_variable_get(:@mp3_player).should be_false
      jj.quit
    end

    it "complains when mpg123 installed but ogg123, mpg321, music123, afplay & play not installed" do
      jj = Jukebox.new
      jj.instance_variable_set(:@ogg_player, nil)
      jj.instance_variable_set(:@mp3_player, nil)
      jj.should_receive(:`).at_least(:once).with("which ogg123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which music123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mpg123").and_return("/usr/bin/mpg123")
      jj.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      jj.should_receive(:`).at_least(:once).with("which play").and_return("")
      jj.should_receive(:puts).with("*** YOU CANNOT PLAY OGG FILES -- YOU MIGHT WANT TO INSTALL OGG123 ***")
      jj.send(:set_music_players)
      jj.instance_variable_get(:@ogg_player).should be_false
      jj.instance_variable_get(:@mp3_player).should == "mpg123"
      jj.quit
    end

    it "complains when mpg321 installed but mpg123, music123, ogg123, afplay & play not installed" do
      jj = Jukebox.new
      jj.instance_variable_set(:@ogg_player, nil)
      jj.instance_variable_set(:@mp3_player, nil)
      jj.should_receive(:`).at_least(:once).with("which ogg123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mpg123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which music123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mpg321").and_return("/usr/bin/mpg321")
      jj.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      jj.should_receive(:`).at_least(:once).with("which play").and_return("")
      jj.should_receive(:puts).with("*** YOU CANNOT PLAY OGG FILES -- YOU MIGHT WANT TO INSTALL OGG123 ***")
      jj.send(:set_music_players)
      jj.instance_variable_get(:@ogg_player).should be_false
      jj.instance_variable_get(:@mp3_player).should == "mpg321"
      jj.quit
    end

    it "prints message and exits when mpg123, mpg321, ogg123, music123, afplay & play all not installed" do
      jj = Jukebox.new
      jj.instance_variable_set(:@ogg_player, nil)
      jj.instance_variable_set(:@mp3_player, nil)
      jj.should_receive(:`).at_least(:once).with("which ogg123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mpg123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which music123").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mpg321").and_return("")
      jj.should_receive(:`).at_least(:once).with("which afplay").and_return("")
      jj.should_receive(:`).at_least(:once).with("which mplayer").and_return("")
      jj.should_receive(:`).at_least(:once).with("which play").and_return("")
      error_msg = "*** YOU CANNOT PLAY MP3S OR OGG FILES -- YOU MIGHT WANT TO INSTALL ogg123 AND mpg123/mpg321 BEFORE USING JIMMYJUKEBOX ***"
      jj.should_receive(:puts).with(error_msg)
      lambda { jj.send(:set_music_players) }.should raise_error SystemExit
      jj.quit
    end

    #it "raises exception when no songs available"
    #  lambda do
    #    jj = Jukebox.new
    #  end.should raise_error
    #end

    it "generates a non-empty song list" do
      jj = Jukebox.new
      jj.instance_variable_get(:@songs).should_not be_nil
      jj.instance_variable_get(:@songs).should_not be_empty
      jj.instance_variable_get(:@songs).length.should be > 0
    end

    it "generates a non-empty song list with only mp3 & ogg files" do
      jj = Jukebox.new
      jj.instance_variable_get(:@songs).each do |song|
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
      sleep 0.2
      jj.loop.should be_true
      jj.playing_pid.should_not be_nil
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
      jj.pause_current_song
      song_2 = jj.playing_pid
      jj.current_song_paused.should be_true
      song_2.should == song_1
      jj.unpause_current_song
      song_3 = jj.playing_pid
      song_3.should == song_2
      jj.current_song_paused.should be_false
      jj.pause_current_song
      song_4 = jj.playing_pid
      song_4.should == song_3
      jj.current_song_paused.should be_true
      song_5 = jj.playing_pid
      song_5.should == song_4
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
