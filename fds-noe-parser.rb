require 'nokogiri'
require 'open-uri'

no_cities = ['C','Q','X']
chars = ('A'..'Z').to_a - no_cities

hp = 'http://www01.noel.gv.at/'
pages = []

for c in chars
  iurl = hp + 'scripts/cms/gem/gem_ssi.asp?B=' + c
  idx = Nokogiri::HTML(open(iurl))

  min = 30
  max = idx.css('a').length - 3

  for i in min..max
    url = hp + idx.css('a')[i]['href']
    pages << url
  end
end

for p in pages
  page = Nokogiri::HTML(open(p))
  page.css('br').each{ |br| br.replace ", " }
  addy = page.css('table#Table1/tr/td').text.
    gsub(/(\n|\t|\r)/,'').
    gsub(/[ ]+/,' ').
    split(/[0-9]{5}\ [A-Za-z ]+,\ /,2)[1].
    split(/,\ [0-9]{4}\ /,2)[0].
    sub(", ", "\t")
  email = page.css('table/tr/td/a')[0].text
  puts addy + "\t" + email
end
