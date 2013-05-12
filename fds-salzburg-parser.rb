require 'nokogiri'
require 'open-uri'

gemeinden = [
  'stadt-salzburg',
  'tennengau',
  'flachgau',
  'pongau',
  'pinzgau',
  'lungau']

b_url = 'http://www.salzburg.gv.at/themen/bezirke/gemeinden/gemeinden-'

for g in gemeinden
  url = b_url + g + '.htm'

  page = Nokogiri::HTML(open(url))
  page.css('br').each{ |br| br.replace ", " }
  c = page.css('table/tr/td').length - 1

  for i in 0..c
    tbtxt = page.css('table/tr/td')[i].text.gsub(/(\n|\t)/,'').gsub(/[ ]+/,' ')
    ahref = page.css('table/tr/td')[i].css('a')

    if tbtxt.include?('E-Mail')
      addy = tbtxt.split(/ [0-9]{4} /, 2)[1].split(', Tel', 2)[0].sub(", ","\t")
      email = ahref.css('a').last['href'].sub('mailto:','')
      puts addy + "\t" + email
    else
      next
    end
  end
end
