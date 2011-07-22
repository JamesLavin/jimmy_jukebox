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

  #def play_loop_in_thread
  #  Thread.new do
  #    play_loop
  #  end
  #end

  def play_loop
    while true do
      play
    end
  end

  def play
    begin
      play_random_song
    rescue SystemExit, Interrupt => e
      terminate_current_song
      puts "\nMusic terminated by user"
      #system('stty', @stty_save)
      exit
    end
  end

  def skip_song
    terminate_current_song
  end

  private

  def play_random_song
    terminate_current_song
    puts "Press Ctrl-C to stop the music and exit this program"
    mp3_file = @songs[rand(@songs.length)]
    play_file(mp3_file)
    #@playing_pid = nil
  end

  def terminate_current_song
    Process.kill("SIGHUP",@playing_pid) if @playing_pid
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
    #         "~/Music/Jelly_Roll_Morton/High Society 1939.mp3"]
  end

  def play_file(mp3_file)
    system_yield_pid("mpg123", File.expand_path(mp3_file)) { |pid|
      @playing_pid = pid 
    }
    @playing_pid = nil
  end

end

jj = Jukebox.new

play_loop_thread = Thread.new do
  jj.play_loop
end

input_thread = Thread.new do
  while true do
    puts "Press 'q' to quit program or 'n' for the next song"
    line = Readline.readline('> ', true)
    case line.strip
    when "q"
      puts "Pressed 'q'"
      Thread.main.exit
    when "n"
      jj.skip_song
    else
      puts "'q' for quit, 'n' for next song"
    end
    puts line
  end
end

play_loop_thread.join
input_thread.join

