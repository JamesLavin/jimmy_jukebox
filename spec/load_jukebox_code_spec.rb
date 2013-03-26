require 'spec_helper'
require_relative '../lib/jimmy_jukebox/handle_load_jukebox_input'

include JimmyJukebox::HandleLoadJukeboxInput

describe "#valid_genre?" do
  
  before do
    ARGV.clear
    ARGV[0] = 'sample'
  end

  it "should recognize 'jazz' as a valid genre" do
    valid_genre?('jazz').should be_true
  end

  it "should recognize 'JAZZ' as a valid genre" do
    valid_genre?('JAZZ').should be_true
  end

  it "should recognize 'classical' as a valid genre" do
    valid_genre?('classical').should be_true
  end

  it "should not recognize 'invalid' as a valid genre" do
    valid_genre?('invalid').should_not be_true
  end

end
