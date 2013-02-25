require 'spec_helper'
require_relative '../lib/jimmy_jukebox/artists'
include Artists

#describe Jukebox do

describe Artists do

  describe "::ARTISTS" do
    it "has the correct keys" do
      Artists::ARTISTS.keys.should include(:ch)
    end

    it "has the correct values for each key" do
      Artists::ARTISTS[:eh].should == { genre: 'JAZZ', name: 'earl_hines' }
    end
  end

  describe "#artist_genre" do
    it "provides the artist's genre" do
      artist_genre(:lvb).should == 'CLASSICAL'
      artist_genre(:jrm).should == 'JAZZ'
    end
  end

  describe "#artist_name" do
    it "provides the artist's name" do
      artist_name(:lh).should == 'lionel_hampton'
      artist_name(:bg).should == 'benny_goodman'
    end
  end

  describe "#artist_name_to_genre" do
    it "provides the artist's genre" do
      artist_name_to_genre('sidney_bechet').should == 'JAZZ'
      artist_name_to_genre('beethoven').should == 'CLASSICAL'
    end
  end

  describe "#artist_name_to_subdir_name" do
    it "provides the artist's subdirectory name" do
      artist_name_to_subdir_name('dixieland').should == '/JAZZ/Dixieland'
      artist_name_to_subdir_name('miles_davis').should == '/JAZZ/Miles_Davis'
      artist_name_to_subdir_name('beethoven').should == '/CLASSICAL/Beethoven'
    end
  end

  describe "#artist_key_to_subdir_name" do
    it "provides the artist's subdirectory name" do
      artist_key_to_subdir_name(:dx).should == '/JAZZ/Dixieland'
      artist_key_to_subdir_name(:md).should == '/JAZZ/Miles_Davis'
      artist_key_to_subdir_name(:lvb).should == '/CLASSICAL/Beethoven'
    end
  end

  describe "#artist_key_to_yaml_file" do
    it "provides the artist's subdirectory name" do
      artist_key_to_yaml_file(:dx).should == 'Dixieland.yml'
      artist_key_to_yaml_file(:md).should == 'MilesDavis.yml'
      artist_key_to_yaml_file(:lvb).should == 'Beethoven.yml'
    end
  end

  describe "#artist_name_to_yaml_file" do
    it "provides the artist's subdirectory name" do
      artist_name_to_yaml_file('dixieland').should == 'Dixieland.yml'
      artist_name_to_yaml_file('miles_davis').should == 'MilesDavis.yml'
      artist_name_to_yaml_file('beethoven').should == 'Beethoven.yml'
    end
  end
end
