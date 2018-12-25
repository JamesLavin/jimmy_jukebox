# require 'pry'

urls = [
  'https://archive.org/download/78_barnyard-blues_eddie-edwards-and-his-original-dixieland-jazz-band-eddie-edwards-max_gbia0032255'
  #'https://archive.org/download/78_boppin-the-blues_lucky-thompson-and-his-lucky-seven-lucky-thompson-benny-carter-bo_gbia0082682'
  #'https://archive.org/download/10IGotRythm'
  #'https://archive.org/details/LionelHamptonHisOrchestraI'
  #'http://archive.org/details/DukeEllington-01-10',
  #'http://archive.org/details/DukeEllington-11-17',
  #'http://archive.org/details/1920s-dukeEllington-01-09'
]
# http://archive.org/details/EddieCochran-01-30
# http://archive.org/details/JackieWilson-01-80

class ArchiveOrgLinkGrabber

  require 'nokogiri'
  require 'open-uri'

  class Links

    attr_accessor :links

    def initialize(lnks)
      self.links = lnks
    end

    def add_links(lnks)
      self.links << lnks
    end

    def only_mp3s
      links.delete_if { |l| !l.match(/\.mp3$/i) }
      self
    end

    def add_archive_org
      links.map! { |l| 'https://archive.org' + l }
      self
    end

    def add_leading_dash
      links.map! { |l| '- ' + l }
      self
    end

    def yaml_formatted
      only_mp3s.add_archive_org.add_leading_dash.links
    end

  end

  attr_accessor :links

  def initialize(urls)
    process_urls(Array(urls))
  end

  def process_urls(urls)
    lnks = []
    urls.each do |url|
      doc = Nokogiri::HTML(open(url))
      lnks = lnks + extract_links(doc)
    end
    self.links = Links.new(lnks)
  end

  def extract_links(doc)
    base_url = doc.css('base').first['href']
    found_links = []
    doc.css('a').each do |link|
      next unless link['href'] =~ /mp3$/
      next if link['href'] =~ /_flat.mp3$/
      next if link['href'] =~ /_CT_EQ.mp3$/
      next if link['href'] =~ /_CT_EQ.mp3$/
      found_links << base_url + link['href']
    end
    found_links
  end

  def yaml_formatted
    links.yaml_formatted
  end

end

puts ArchiveOrgLinkGrabber.new(urls).yaml_formatted

