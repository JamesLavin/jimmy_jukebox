url = 'http://archive.org/details/VincentLopezOrchestra-01-10Of10'
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

    def only_mp3s
      links.delete_if { |l| !l.match(/\.mp3$/i) }
      self
    end

    def add_archive_org
      links.map! { |l| 'http://archive.org' + l }
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

  attr_accessor :doc, :links

  def initialize(url)
    self.doc = Nokogiri::HTML(open(url))
    self.links = Links.new(extract_links(doc))
  end

  def extract_links(doc)
    found_links = []
    doc.css('a').each do |link|
      found_links << link['href']
    end
    found_links
  end

  def yaml_formatted
    links.yaml_formatted
  end

end

puts ArchiveOrgLinkGrabber.new(url).yaml_formatted

