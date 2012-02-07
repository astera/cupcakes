#--------------------------------={ preamble }=--------------------------------#
# This script was specifically designed to work with titanpad.com, a friendly  #
# offspring of the original EtherPad (and unfortunately running on a bitchy    #
# lil' Jetty server).                                                          #
# Shouts go out to Robe, for - nevertheless! - running that box, and to fin    #
# for making me write this thing [and adding a new feature to net-http-persis- #
# tent and mechanize underway], and to the maintainers of these libraries.     #
# Oh, and <3s to joernchen.                                                    #
# Stay cool, kids -- /a                                                        #
#------------------------------------------------------------------------------#

require 'rubygems'
require 'mechanize'

#-----------------------------------={ AI }=-----------------------------------#
# ...                                                                  *cough* #

mech_err = "
Sorry dear, but you're currently running an outdated version of Mechanize o.O
Setting the ssl_version (crucial for Titanpad, which is running on a Jetty 6.1.20) is only possible starting from Mechanize 2.1.2!
See https://github.com/tenderlove/mechanize/commit/4a228899855e0676ab69c2bf548170c8717465d8 as well as the corresponding net-http-persistent update
https://github.com/drbrain/net-http-persistent/commit/5f4a945ccf59538cea63323ccb705ad1a7349477 for more info and delight.

We'll proceed anyways and see how that goes - brace for impact in case I bail out.
\n"

args_err = "There's no way around providing me with the URL to your EtherPad server, login (i.e. mail address) & password.
If you feel like it, you may also specify a filename to save the downloaded zip archive as, like so:

#{$0} URL login password [filename]"

ca_file_missing = "I'll need you to go ahead and install the curl-ca-bundle for me, so I can check on that whole SSL thing and stuff.
You should save that under /opt/local/share/curl/curl-ca-bundle.crt - you have 30 seconds to comply."

#------------------------------------------------------------------------------#

begin
  gem 'mechanize', '~> 2.1.2'
  titan_ssl = 1
rescue LoadError
  puts mech_err
  titan_ssl = 0
end

abort args_err if (ARGV.size < 3)

url = 'https://' + ARGV[0]
login = ARGV[1]
passwd = ARGV[2]
filename = 'all-pads.zip'

if (ARGV.size > 3)
  filename = ARGV[3]
end

ca_bundle = '/opt/local/share/curl/curl-ca-bundle.crt'

a = Mechanize.new { |agent|

  if File.exists?(ca_bundle)
    agent.ca_file = ca_bundle
  else
    puts ca_file_missing
    sleep 30
  end

  if (titan_ssl == 1)
    agent.ssl_version = "SSLv3"
  end
}

a.get(url) do |page|
  home_page = page.form_with(:id => 'signin-form') do |field|
    field.email = login
    field.password = passwd
  end.submit

  padlist_page = a.click(home_page.link_with(:text => "Pads"))

  a.pluggable_parser.default = Mechanize::Download
  a.click(padlist_page.link_with(:text => "Download all pads as a ZIP archive")).save(filename)
end
