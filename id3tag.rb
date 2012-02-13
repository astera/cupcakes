require 'mp3info'

#------------------------------={ INTRODUCTION }=------------------------------#

intro = "
Once upon a time, there lived a little DJ, in a big, wild world with
weirdly tagged or untagged or re-tagged mp3 files all over the place - and all
he would've asked for was just a wee bit of order. Back then (he still vividly
remembered the days when he used to walk through man-high snow, barefoot, uphill
both ways and... well, you get the idea), the DJing business was hard enough to
be honest.
Now, one day, a fairy little fairy (true story!) would listen to one of his gigs
by chance, and was so amazed by the deep house and tech house and what-not he
mixed, that she'd approach him and granted him a wish - and oh, our dear DJ did
know _exactly_ what he wanted!
He placed the tiny bot he was given by our fair fairy in his folder with freshly
hunted-down tracks, and the bot would make sure all ID3 tags were kept clean...
that meaning, discarded of; and the artist & title taken from the file names of
all .mp3s present in said directory written in ID3v2.

If this, all of a sudden, does not sound like a good idea to you or you're not
feeling like our little DJ - then you have 3 seconds to interrupt this script.
Otherwise, again, ALL TAGS OF ALL MP3 FILES WITHIN THIS DIRECTORY WILL BE LOST.
Amen.
\n"

#------------------------------------------------------------------------------#

puts intro
sleep 23

low_bitrate = Array.new()
filename_error = Array.new()
fopen_error = Array.new()
count = 0

Dir.entries('.').each do |file|
  # we're only interested in .mp3 files
  next if file !~ /\.mp3$/

  # we need a 'proper' filename to work with
  if file !~ / - /
    filename_error << file
    next
  end

  begin
    Mp3Info.open(file) do |mp3|
      filename = mp3.filename.split(" - ")
      title = filename[1].gsub(/.mp3$/, '')
      artist = filename[0]

      # delete ALL the tags o/
      mp3.removetag1
      mp3.removetag2

      # write artist & title ID3v2 tags
      mp3.tag2.TIT2 = title
      mp3.tag2.TPE1 = artist

=begin
      You may also access the following tags, if you like:

      __ID3v1 tags__
      title
      artist
      album
      year
      tracknum
      comments
      genre
      genre_s

      __ID3v2 tags__
      TRCK # track #/#
      TIT1 # content
      TIT2 # title
      TIT3 # subtitle
      TPE1 # artist
      TPE2 # orchestra
      TPE3 # conductor
      TALB # album
      TYER # year
      TCON # genre
      COMM # comment
      TCOM # composer
      TCOP # copyright
      TOPE # orig. artist
      TENC # encoded by
      WXXX # URL
      TCMP # part of compilation?
      TEXT # lyricist
      TPUB # publisher
      TPOS # part of set #/#
      disc_number # part of set
      disc_total # number of parts of set
      TSRC # ISRC
      TBPM # bpm
      TKEY # key
      USLT # lyrics
      APIC # pictures
=end

      if (mp3.bitrate < 320)
        low_bitrate << mp3.filename
      end

      puts "Tags written to #{artist} - #{title}"
      count += 1
    end
  rescue Mp3InfoError
    fopen_error << file
  end
end

#-----------------------={ EXECUTIVE SUMMARY OF FAIL: }=-----------------------#

puts "
Processed & tagged #{count} mp3 files."

if (low_bitrate.count > 0)
  puts "
WARNING! The following mp3s have under 320kbps:"
  low_bitrate.each do |file|
    puts file
  end
  puts "I would rather not recommend using these for DJing purposes, honey!"
end

if (fopen_error.count > 0)
  puts "
ERROR! The following mp3s could not be processed; plz check on the files' permissions and/or integrity:"
  fopen_error.each do |file|
    puts file
  end
end

if (filename_error.count > 0)
  puts "
ERROR! The following mp3s (or their tags, respectively) did not get modified:"
  filename_error.each do |file|
    puts file
  end
  puts "A filename should be formatted to resemble the following example: Artist - Title.mp3"
end
