require 'readline'

# make system call and get pid so you can terminate process
def system_yield_pid(*cmd)
  pid = fork do
    exec(*cmd)
    exit! 127
  end
  yield pid if block_given?
  Process.waitpid(pid)
  $?
end

class Jukebox

  attr_reader :stty_save, :current_song_paused, :playing_pid

  def initialize
    @stty_save = `stty -g`.chomp
    generate_directories_list
    generate_song_list
  end

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
      system('stty', @stty_save)
      exit
    end
  end

  def skip_song
    terminate_current_song
  end

  def pause_current_song
    @current_song_paused = true
    system("kill -s STOP #{@playing_pid}") if @playing_pid
  end

  def unpause_current_song
    @current_song_paused = false
    system("kill -s CONT #{@playing_pid}") if @playing_pid
  end

  private

  def generate_top_dirs
    @music_directories_file = 'all.txt'
    generate_top_dirs_from_file if ARGV[0] && ARGV[0].match(/.*\.txt/)
  end

  def generate_top_dirs_from_file
    @music_directories_file = ARGV[0] if ARGV[0] && ARGV[0].match(/.*\.txt/)
  end

  def play_random_song
    terminate_current_song
    puts "Press Ctrl-C to stop the music and exit this program"
    mp3_file = @songs[rand(@songs.length)]
    play_file(mp3_file)
  end

  def terminate_current_song
    Process.kill("SIGHUP",@playing_pid) if @playing_pid
  end

  def generate_directories_list
    generate_top_dirs
    load_top_level_directories_from_file
    add_all_subdirectories
  end

  def load_top_level_directories_from_file
    @mp3_directories = []
    File.open(@music_directories_file, "r") do |inf|
      while (line = inf.gets)
        line.strip!
        @mp3_directories << File.expand_path(line)
      end
    end
  end

  def add_all_subdirectories
    new_dirs = []
    @mp3_directories.each do |dir|
      Dir.chdir(dir)
      new_dirs += Dir.glob("**/")
    end
    @mp3_directories += new_dirs
  end

  def generate_song_list
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
    system_yield_pid("mpg123", File.expand_path(mp3_file)) do |pid|
      @playing_pid = pid 
    end
    @playing_pid = nil
  end

end

jj = Jukebox.new

play_loop_thread = Thread.new do
  jj.play_loop
end

input_thread = Thread.new do
  display_string = "Press 'p' to (un)pause, 'q' to quit, or 's' to skip the song"
  begin
    while true do
      puts display_string
      line = Readline.readline('> ', true)
      case line.strip
      when "q"
        puts "Quit requested"
        playing_pid = jj.playing_pid if play_loop_thread && jj.playing_pid
        play_loop_thread.exit
        Process.kill("SIGHUP",playing_pid) if playing_pid
        Thread.main.exit
      when "p"
        if play_loop_thread && jj.current_song_paused
          puts "Unpause requested"
          jj.unpause_current_song
          #play_loop_thread.run
        elsif play_loop_thread
          puts "Pause requested"
          jj.pause_current_song
          #play_loop_thread.stop
        else
          raise "Can't find play_loop_thread"
        end
        puts display_string
      when "s"
        puts "Skip song requested"
        jj.skip_song
      else
        puts display_string
      end
    end
  rescue Interrupt => e
    puts "\nMusic terminated by user"
    system('stty', jj.stty_save)
    exit
  end
end

play_loop_thread.join
input_thread.join

