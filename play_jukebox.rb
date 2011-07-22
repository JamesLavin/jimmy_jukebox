require 'readline'

def system_yield_pid(*cmd)
  pid = fork do
    exec(*cmd)
    exit! 127
  end
  yield pid if block_given?
  Process.waitpid(pid)
  $?
end

class Jukebox < Array

  def initialize
    #@stty_save = `stty -g`.chomp
    @music_directories_file = 'jimmy_jukebox_directories.txt'
    @music_directories_file = ARGV[0] if ARGV[0] && ARGV[0].match(/.*\.txt/)
    generate_song_list
  end

  def play
    begin
      play_random_song
    rescue SystemExit, Interrupt => e
      Process.kill("SIGHUP",@playing_pid)
      puts "\nMusic terminated by user"
      #system('stty', @stty_save)
      exit
    end while true
  end

  private

  def play_random_song
    puts "Press Ctrl-C to stop the music and exit this program"
    mp3_file = @songs[rand(@songs.length)]
    @playing_pid = play_file(mp3_file)
  end

  def generate_directories_list
    @mp3_directories = []
    File.open(@music_directories_file, "r") do |inf|
      while (line = inf.gets)
        line.strip!
        @mp3_directories << File.expand_path(line)
      end
    end
  end

  def generate_song_list
    generate_directories_list
    @songs = []
    @mp3_directories.each do |mp3_dir|
      files = Dir.entries(File.expand_path(mp3_dir))
      files.delete_if { |f| !f.match(/.*\.mp3/) }
      files.map! { |f| File.expand_path(mp3_dir) + '/' + f }
      @songs = @songs + files
    end
    #songs = ["~/Music/Artie_Shaw/Georgia On My Mind 1941.mp3",
    #         "~/Music/Artie_Shaw/Dancing In The Dark 1941.mp3",
    #         "~/Music/Jelly_Roll_Morton/Georgia Swing 1928.mp3",
    #         "~/Music/Jelly_Roll_Morton/High Society 1939.mp3"]
  end

  def play_file(mp3_file)
    system_yield_pid("mpg123", File.expand_path(mp3_file)) { |pid|
      @playing_pid = pid 
    }
  end

end

input_thread = Thread.new do
  loop do
    puts "Press 'q' to quit program and stop playing music"
    line = Readline.readline('> ', true)
    exit if line.strip == "q"
    puts line
  end
end

jj = Jukebox.new
jj.play

