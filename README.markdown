# JimmyJukebox

## DESCRIPTION

JimmyJukebox enables you to: 1) Play your music; and, 2) Download wonderful old jazz

JimmyJukebox plays MP3/OGG songs in random order. You can pause/unpause a playing song, skip a song, or quit. By default, JimmyJukebox will play all .mp3 and .ogg files in your `~/Music` directory tree (including subdirectories). You can specify a different top music directory by passing a directory name as a command line parameter (example: `play_jukebox ~/Music/JAZZ`). Or you can pass the name of a text file containing a list of directory names.

JimmyJukebox also enables you to download thousands of great jazz performances by Art Tatum, Artie Shaw, Bennie Moten, Benny Goodman, Billie Holiday, Bix Beiderbecke, Charlie Christian, Count Basie, Dizzy Gillespie, Django Reinhardt, Duke Ellington, Fletcher Henderson, Jelly Roll Morton, Lionel Hampton, Louis Armstrong, the Original Dixieland Jazz Band, and Red Norvo.

## REQUIREMENTS

Linux/Unix:

- Playing MP3s requires `mplayer`, `mpg123`, `mpg321`, `music123` or `play` (package name: `sox`)
- Playing OGG files requires `mplayer`, `ogg123`, `music123` or `play` (package name: `sox`)

Mac:

- No additional requirements. Should play MP3s and OGG files using built-in `afplay`.
- Currently testing. Downloading music works fine. Playing first song is fine, and pausing the song works fine. But -- under Ruby 1.8 -- it won't start playing a second song when the first finishes or let the user skip to a second song. I believe the problem relates to my use of threads and fork...exec, but I haven't found a Ruby 1.8 solution. I tried [POpen4](http://popen4.rubyforge.org/), but it appears to not be threadsafe. The same code seems to work on Macs under Ruby 1.9.

Windows:

- JimmyJukebox currently does not currently run on Windows, though we hope to get it working
- You should install `mplayer`

JRuby:

- I love JRuby, but JimmyJukebox does not currently work on JRuby because JRuby does not support `fork` (see TROUBLESHOOTING below)

## QUICK-START INSTRUCTIONS

- Download music: `load_jukebox [artist name]` (see next section)
- Play music: `play_jukebox`

## BASIC USAGE - DOWNLOADING MUSIC

Warning: Songs average approximately 2.5MB or 3MB.

To download music, use this on the command line:

    Art Tatum:                    "load_jukebox at"   (168 songs)
    Artie Shaw:                   "load_jukebox as"   (580 songs)
    Bennie Moten:                 "load_jukebox bm"   (107 songs)
    Benny Goodman:                "load_jukebox bg"   (401 songs)
    Billie Holiday:               "load_jukebox bh"   ( 63 songs)
    Bix Beiderbecke:              "load_jukebox bb"   ( 95 songs)
    Charlie Christian:            "load_jukebox cc"   (  8 songs)
    Count Basie:                  "load_jukebox cb"   ( 44 songs)
    Dizzy Gillespie:              "load_jukebox dg"   (  3 songs)
    Django Reinhardt:             "load_jukebox dr"   ( 75 songs)
    Duke Ellington:               "load_jukebox de"   (158 songs)
    Fletcher Henderson:           "load_jukebox fh"   (158 songs)
    Jelly Roll Morton:            "load_jukebox jrm"  ( 89 songs)
    Lionel Hampton:               "load_jukebox lh"   (148 songs)
    Louis Armstrong:              "load_jukebox la"   (150 songs)
    Original Dixieland Jazz Band: "load_jukebox odjb" ( 45 songs)
    Red Norvo:                    "load_jukebox rn"   ( 39 songs)

By default, music will be downloaded to a directory under `~/Music/JAZZ/`, like `~/Music/JAZZ/Original_Dixieland_Jazz_Band` (and that directory will be created automatically).

To specify a different directory, type the full directory path after `load_jukebox`, e.g.: `load_jukebox "/home/my_name/MyMusic/Jazz/ODJB"`. Place the directory path in quotation marks if it contains any spaces or other "unusual" characters.

## BASIC USAGE - PLAYING MUSIC

- On the command line, type `play_jukebox`
- By default, JimmyJukebox assumes your music is stored in a directory tree descending from `~/Music`
- A song will start playing
- To skip to the next song, type `s<RETURN>`
- To pause the song, type `p<RETURN>`
- To restart a paused song, type `p<RETURN>`
- To quit, type "q<RETURN>" or `<CTRL>-C`

## TELLING JIMMYJUKEBOX WHERE TO FIND YOUR MUSIC

### Method 1 selects just one music directory tree:

- On the command line, type `play_jukebox DIRECTORY_NAME` where DIRECTORY_NAME is the path to the top of your music directory tree

- If your directory name contains characters that must be escaped, you can either escape them or enclose the string in double quotation marks

- For example:
    play_jukebox ~/Music/JAZZ
    play_jukebox ~/Music/The\ Beatles
    play_jukebox "~/Music/The Beatles"
    play_jukebox ~/Music/JAZZ/Jack\ Sheedy\'s\ Dixieland\ Jazz\ Band
    play_jukebox "~/Music/JAZZ/Jack Sheedy's Dixieland Jazz Band"

### Method 2 selects one or more music directory trees:

- Create a `~/.jimmy_jukebox` directory

- Create a file (or files) in `~/.jimmy_jukebox` named whatever you want but ending in `.txt`
    ~/.jimmy_jukebox/jazz.txt
    ~/.jimmy_jukebox/rock.txt
    ~/.jimmy_jukebox/country.txt
    etc.

- Inside each file, each row names the top of a music directory tree (no need to escape spaces and other frequently escaped characters). For example, `~/.jimmy_jukebox/rock.txt` might contain the following:
    ~/My_rock_files/The_Beatles
    ~/My_rock_files/The Eagles
    /home/my_name/My_rock_files/The_Rolling_Stones

- To play music stored in the directory trees specified in `~/.jimmy_jukebox/jazz.txt`, run `play_jukebox jazz.txt`.

## TROUBLESHOOTING

- Are you running a Windows machine? Solution: Get a real Unix/Linux/Mac machine.

- Are you running JRuby? Solution: Set your GEM_HOME and PATH variables to call "Matz" Ruby (aka MRI, CRuby and "regular" Ruby) before calling JRuby (OPTIONAL: then contact the JRuby gurus and very nicely encourage them to enable `fork`)

If you're a JRuby user (like me), you may be disappointed that JimmyJukebox doesn't work with JRuby. JRuby generates a "NotImplementedError: fork is not available on this platform" exception because "JRuby doesn't implement fork() on any platform, including those where fork() is available in MRI" (http://kenai.com/projects/jruby/pages/DifferencesBetweenMriAndJruby#Fork_is_not_implemented). There is an experimental "fork" feature in JRuby callable on the command line with "-J-Djruby.fork.enabled=true" but the feature is labelled "(EXPERIMENTAL, maybe dangerous)" (see http://kenai.com/projects/jruby/pages/PerformanceTuning#Native_Support_Runtime_Properties).

## LEGAL DISCLAIMER

Download music at your own risk. I DO NOT guarantee that any music this program enables you to download is in the public domain, but the music is all from a reputable website (archive.org), and most/all of the songs seem to have been uploaded by someone who vouched that they are now in the public domain. Many of the songs are old enough that they are no longer eligible for copyright protection. More recently recorded songs may or may not be in the public domain, but copyright law is very complex, and it is often difficult or impossible to determine whether or not a particular song currently enjoys copyright protection.

