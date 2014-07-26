require 'nokogiri'
require 'open-uri'

#------------------------------------------------------------------------------#
#                SO YOU'D LIKE TO EXPORT YOUR BLIPS, CONGRATS!                 #
#                                                                              #
# While fairly dumb, this script will export all track titles of your (or any- #
# one else's, really) blip.fm stream, as many pages back as you like, starting #
# from the most recent blip.                                                   #

args_err = "Please provide this script with your blip.fm permalink,
the number of pages (most recent first) of blips to export,
and a filepath to save the blip titles to, like so:

#{$0} permalink pages filename"

#------------------------------------------------------------------------------#

abort args_err if (ARGV.size != 3)

permalink = ARGV[0]
num_pages = ARGV[1].to_i
filename  = ARGV[2]

file = File.open(filename, "w")
b_url = "http://blip.fm/#{permalink}?page="

for i in 1..num_pages
  url = b_url + i.to_s
  page = Nokogiri::HTML(open(url))
  blips = page.css("div#blipsContainer a[class='clickable blipTypeIcon']")
  blips.collect { |b| file.write(b["title"].sub("search for ", "").gsub(/\\/, "").gsub(/$/, "\n")) }
end

file.close
