# JimmyJukebox

## DESCRIPTION

JimmyJukebox enables you to: 1) Download wonderful bluegrass, classical, jazz and early rock music; and, 2) Play it and your other music.

JimmyJukebox plays MP3/OGG songs in random order. You can pause/unpause a playing song, skip a song, or quit. By default, JimmyJukebox will play all .mp3, .ogg, .flac and .wav files in your `~/Music` directory tree (including subdirectories). You can specify a different top music directory by passing a directory name as a command line parameter (example: `play_jukebox ~/Music/JAZZ`). Or you can pass the name of a text file containing a list of directory names.

JimmyJukebox also enables you to download thousands of great jazz performances by Art Tatum, Artie Shaw, Bennie Moten, Benny Goodman, Billie Holiday, Bix Beiderbecke, Cannonball Adderley, Charlie Christian, Charlie Parker, Clifford Hayes, Coleman Hawkins, Count Basie, Dizzy Gillespie, Django Reinhardt, Duke Ellington, Earl Hines, Fletcher Henderson, Glenn Miller, James P Johnson, Jelly Roll Morton, John Coltrane, King Oliver, Les Brown, Lionel Hampton, Louis Armstrong, Miles Davis, the Original Dixieland Jazz Band, Oscar Peterson, Red Norvo, Scott Joplin, and Sidney Bechet.

You can also download wonderful old classical music performances composed by Bach, Beethoven, Brahms, Chopin, Haydn, Mendelssohn, Mozart, Ravel, Schubert and Vivaldi. (You have my 6-year-old son to thank for the classical music. When JimmyJukebox was all jazz, he asked whether I had any Beethoven. After I added Beethoven and Haydn, I expected he would be pleased. Instead, he asked, "but do you have any Mozart, Vivaldi or Bach?" He even used the German pronunciation of Bach! He attends an awesome school that teaches such things!)

And I'm adding three more truly American inventions:

1) Bluegrass -- starting with greats Earl Scruggs (and Lester Flatt) and Bill Monroe
2) Jugband
3) Rock -- starting with the Big Bopper, Bill Haley (and The Comets), Buddy Holly (and The Crickets), Carl Perkins, Chubby Checker, Chuck Berry, The Coasters, Curtis Lee, Elvis, The Everly Brothers, Jerry Lee Lewis, Little Richard, Richie Valens, The Righteous Brothers, The Rivieras, The Rolling Stones, and Roy Orbison.

## REQUIREMENTS

Linux/Unix:

- Playing MP3s requires `mplayer`, `mpg123`, `mpg321`, `music123`, `cvlc`, `amarok` or `play` (package name: `sox`)
- Playing OGG files requires `mplayer`, `ogg123`, `music123`, `cvlc`, `amarok` or `play` (package name: `sox`)
- Playing FLAC files requires `mplayer`, `cvlc` or `play` (package name: `sox`)
- Playing WAV files requires `mplayer`, `cvlc`, `aplay` or `play` (package name: `sox`)
- Requires the `posix-spawn` Ruby gem (or `spoon` gem, if JRuby)
- On my machine, runs well with 1.9.2-p320 and 1.9.3-p327

Mac:

- No additional requirements. The built-in `afplay` should play MP3, OGG, FLAC and WAV files.

JRuby:

- Install the `spoon` gem (necessary because JRuby doesn't enable `fork` or run the `posix-spawn` gem)
- Runs well on my computer using JRuby 1.6.7.2, 1.7.1 and 1.7.3.

Windows:

- JimmyJukebox has not been tested on Windows and probably will NOT work "as is."
- You could try running it after installing `mplayer`

## QUICK-START INSTRUCTIONS

- Download music:
  - Load all music for an artist: `load_jukebox [artist name]` (see next section)
  - Load 8 songs for an artist: `load_jukebox [artist name] 8` (see next section)
  - Load sample of 20 songs from all genres: `load_jukebox sample 20`
  - Load sample of 10 songs from a genre: `load_jukebox jazz 10` (valid genres: 'banjo' 'bluegrass' 'classical' 'jazz' 'rock')
  - List all artists with their symbols: `load_jukebox artists`

- Play downloaded music:
  - Play artist: `play_jukebox [artist code]` (see next section)
  - Play all music in default directory tree ("~/Music"): `play_jukebox`
  - Play music in user-specified directory tree: `play_jukebox [top directory name]`

## BASIC USAGE - DOWNLOADING MUSIC

Warning: Downloading every available song would consume 15GB of your hard drive. At last count, the 2,222 jazz songs take up 7.3 GB (~ 3.3 MB/song). The roughly 657 classical performances also take up 6 GB (~ 9.1 MB/piece). The 243 bluegrass songs take up 822 MB (~ 3.4 MB/song). And the 126 rock songs are about 420 MB (~ 3.3 MB/song).

To download a limited number of songs by an artist, add the number of songs you want after the artist's initials. For example, to download just 15 pieces by Beethoven (lvb), type:

    Beethoven:                    "load_jukebox lvb 15"

To download all songs by an artist, use the following commands:

    BLUEGRASS
    Earl Scruggs:                 "load_jukebox es"    ( 88 songs)
    Bill Monroe:                  "load_jukebox mon"   (155 songs)
    Hot Buttered Rum String Band  "load_jukebox hbrsb" ( 10 songs)

    CLASSICAL
    Bach:                         "load_jukebox jsb"   (153 songs)
    Beethoven:                    "load_jukebox lvb"   ( 49 songs)
    Brahms:                       "load_jukebox jb"    ( 78 songs)
    Chopin:                       "load_jukebox fc"    ( 47 songs)
    Haydn:                        "load_jukebox h"     ( 47 songs)
    Mendelssohn:                  "load_jukebox m"     ( 57 songs)
    Mozart:                       "load_jukebox wam"   (141 songs)
    Ravel:                        "load_jukebox mr"    ( 33 songs)
    Schubert:                     "load_jukebox fs"    ( 38 songs)
    Vivaldi:                      "load_jukebox v"     ( 52 songs)

    JAZZ
    Art Tatum:                    "load_jukebox at"    (168 songs)
    Artie Shaw:                   "load_jukebox as"    (580 songs)
    Bennie Moten:                 "load_jukebox bm"    (107 songs)
    Benny Goodman:                "load_jukebox bg"    (401 songs)
    Billie Holiday:               "load_jukebox bh"    ( 63 songs)
    Bix Beiderbecke:              "load_jukebox bb"    ( 95 songs)
    Cannonball Adderley:          "load_jukebox ca"    (  7 songs)
    Charlie Christian:            "load_jukebox cc"    (  8 songs)
    Charlie Parker:               "load_jukebox cp"    ( 34 songs) [Archive.org has apparently removed many of these]
    Clifford Hayes Jug Blowers:   "load_jukebox chjb"  ( 15 songs)
    Coleman Hawkins:              "load_jukebox ch"    ( 16 songs)
    Count Basie:                  "load_jukebox cb"    ( 44 songs)
    Dixieland (various artists):  "load_jukebox dx"    (  8 songs)
    Dizzy Gillespie:              "load_jukebox dg"    (  3 songs)
    Django Reinhardt:             "load_jukebox dr"    ( 75 songs)
    Duke Ellington:               "load_jukebox de"    (158 songs)
    Earl Hines:                   "load_jukebox eh"    ( 98 songs)
    Fletcher Henderson:           "load_jukebox fh"    (158 songs)
    Glenn Miller:                 "load_jukebox gm"    (211 songs)
    James P Johnson:              "load_jukebox jj"    (  8 songs)
    Jelly Roll Morton:            "load_jukebox jrm"   ( 89 songs)
    Jazz medleys (various):       "load_jukebox jm"    ( 13 songs) [some are long radio broadcasts]
    John Coltrane:                "load_jukebox jc"    ( 10 songs)
    King Oliver:                  "load_jukebox ko"    ( 60 songs)
    Les Brown:                    "load_jukebox lb"    ( 41 songs)
    Lionel Hampton:               "load_jukebox lh"    (148 songs)
    Louis Armstrong:              "load_jukebox la"    (150 songs)
    Miles Davis:                  "load_jukebox md"    ( 62 songs)
    Modern Jazz Quartet:          "load_jukebox mjq"   (  3 songs)
    Original Dixieland Jazz Band: "load_jukebox odjb"  ( 45 songs)
    Oscar Peterson:               "load_jukebox op"    ( 10 songs) [one "song" is > 2 hour performance]
    Ragtime (various artists):    "load_jukebox rt"    ( 14 songs)
    Red Norvo:                    "load_jukebox rn"    ( 39 songs)
    Scott Joplin:                 "load_jukebox sj"    ( 10 songs)
    Sidney Bechet:                "load_jukebox sb"    ( 25 songs)

    ROCK
    The Big Bopper:               "load_jukebox bop"   ( 21 songs)
    Bill Haley & the Comets:      "load_jukebox bhc"   ( 63 songs)
    Buddy Holly:                  "load_jukebox holly" ( 57 songs)
    Carl Perkins:                 "load_jukebox carl"  ( 89 songs)
    Chubby Checker:               "load_jukebox check" ( 52 songs)
    Chuck Berry:                  "load_jukebox berry" (127 songs)
    The Coasters:                 "load_jukebox coast" ( 18 songs)
    Curtis Lee:                   "load_jukebox cl"    ( 20 songs)
    Elvis Presley:                "load_jukebox e"     (314 songs)
    The Everly Brothers:          "load_jukebox eb"    ( 20 songs)
    Jerry Lee Lewis:              "load_jukebox jll"   (260 songs)
    Little Richard:               "load_jukebox lr"    ( 26 songs)
    Richie Valens:                "load_jukebox rv"    (  6 songs)
    The Righteous Brothers:       "load_jukebox rb"    ( 33 songs)
    The Rivieras:                 "load_jukebox riv"   ( 56 songs)
    The Rolling Stones:           "load_jukebox rs"    (  5 songs) (one is an album)
    Roy Orbison:                  "load_jukebox ro"    ( 79 songs)

    OTHER
    Archibald Camp (banjo):       "load_jukebox acb"   ( 20 songs) (old banjo songs)
    Jugband:                      "load_jukebox jug"   ( 13 songs)

By default, music will be downloaded to a directory under `~/Music/JAZZ/`, like `~/Music/JAZZ/Original_Dixieland_Jazz_Band` (and that directory will be created automatically).

To specify a different directory, type the full directory path after `load_jukebox`, e.g.: `load_jukebox "/home/my_name/MyMusic/Jazz/ODJB"`. Place the directory path in quotation marks if it contains any spaces or other "unusual" characters.

## BASIC USAGE - PLAYING MUSIC

- By default, JimmyJukebox assumes your music is stored in a directory tree descending from `~/Music`
- By default:
  - Bluegrass is stored under `~/Music/BLUEGRASS`
  - Classical is stored under `~/Music/CLASSICAL`
  - Jazz is stored under `~/Music/JAZZ`
  - Jazz is stored under `~/Music/ROCK`

- To play a random selection of music, type in the command line `play_jukebox`
  - A song will start playing
  - To skip to the next song, type `s`
  - To pause the song, type `p`
  - To restart a paused song, type `p`
  - To erase the playing song and never hear it again, type `e`
  - To quit, type "q" or `<CTRL>-C`

- To play a random selection of...
  - Bluegrass: `play_jukebox bluegrass` or `play_jukebox b`
  - Classical: `play_jukebox classical` or `play_jukebox c`
  - Jazz: `play_jukebox jazz` or `play_jukebox j`
  - Rock: `play_jukebox rock` or `play_jukebox r`

- To play a particular artist, type:

    Art Tatum:                    "play_jukebox at"
    Artie Shaw:                   "play_jukebox as"
    Bennie Moten:                 "play_jukebox bm"
    Haydn:                        "load_jukebox h"
    etc.

## TELLING JIMMYJUKEBOX WHERE TO FIND YOUR MUSIC

### Method 1 selects just one music directory tree:

- On the command line, type `play_jukebox DIRECTORY_NAME` where DIRECTORY_NAME is the path to the top of your music directory tree

- If your directory name contains characters that must be escaped, you can either escape them or enclose the string in double quotation marks

- For example:
  - play_jukebox ~/Music/JAZZ
  - play_jukebox ~/Music/The\ Beatles
  - play_jukebox "~/Music/The Beatles"
  - play_jukebox ~/Music/JAZZ/Jack\ Sheedy\'s\ Dixieland\ Jazz\ Band
  - play_jukebox "~/Music/JAZZ/Jack Sheedy's Dixieland Jazz Band"

### Method 2 selects one or more music directory trees:

- Create a `~/.jimmy_jukebox` directory

- Create one or more files in `~/.jimmy_jukebox` named whatever you want but ending in `.txt`. Each will become a playlist:
  - ~/.jimmy_jukebox/jazz.txt
  - ~/.jimmy_jukebox/rock.txt
  - ~/.jimmy_jukebox/country.txt
  - etc.

- Inside each file, add a row name for each top-level music directory tree for that playlist. (No need to escape spaces and other frequently escaped characters.) For example, `~/.jimmy_jukebox/rock.txt` might contain the following:
  - ~/My_rock_files/The_Beatles
  - ~/My_rock_files/The Eagles
  - /home/my_name/My_rock_files/The_Rolling_Stones

- To play music stored in the playlist (directory trees) specified in `~/.jimmy_jukebox/jazz.txt`, run `play_jukebox jazz.txt`.

## TROUBLESHOOTING

- Are you running a Windows machine? Solution: Get a real Unix/Linux/Mac machine.

- Are you running JRuby? Solution: Have you installed the `spoon` gem?

- Still having problems? Please let me (j a m e s AT j a m e s l a v i n DOT c o m) know your operating system, Ruby environment and problem. I learned far more about the nuances of fork, exec, system, \`\`, spawnp and related commands and how they're implemented (differently) on various versions of Ruby than I ever wanted (or imagined possible). In fact, I wasted more time struggling over these glitches than writing JimmyJukebox.

## LEGAL DISCLAIMER

Download music at your own risk. I DO NOT guarantee that any music this program enables you to download is in the public domain, but the music is all from a reputable website (archive.org), and most/all of the songs seem to have been uploaded by someone who vouched that they are now in the public domain. Many of the songs are old enough that they are no longer eligible for copyright protection. More recently recorded songs may or may not be in the public domain, but copyright law is very complex, and it is often difficult or impossible to determine whether or not a particular song currently enjoys copyright protection.

