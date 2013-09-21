require 'nokogiri'
require 'open-uri'

url = 'http://archive.org/details/JamesTaylorJoniMitchell'
# http://archive.org/details/EddieCochran-01-30
# http://archive.org/details/JackieWilson-01-80

doc = Nokogiri::HTML(open(url))

def all_links(doc)
  links = []
  doc.css('a').each do |link|
    links << link['href']
  end
  links
end

def only_mp3s(links)
  links.delete_if { |l| !l.match(/\.mp3$/i) }
end

def add_archive_org(links)
  links.map! { |l| 'http://archive.org' + l }
end

def add_leading_dash(links)
  links.map! { |l| '- ' + l }
end

links = add_leading_dash(add_archive_org(only_mp3s(all_links(doc))))

puts links
