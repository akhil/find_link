require 'rubygems'
require 'pp'
begin
  require 'twitter'
rescue LoadError => e
  puts e
  puts " twitter gem not found.\n Please install twitter.\n gem install twitter"
  exit
end

if ARGV.size == 0
  puts "hashtag not found...exiting"
  exit
end

require 'open-uri'
#Monkey patching to allow for http -> https redirect
module OpenURI
  def OpenURI.redirectable?(uri1, uri2)
    uri1.scheme.downcase == uri2.scheme.downcase ||
      (/\A(?:http|https|ftp)\z/i =~ uri1.scheme && /\A(?:http|https|ftp)\z/i =~ uri2.scheme)
  end
end

statuses = Twitter::Search.new.q("##{ARGV[0]}").result_type("recent").per_page(100).fetch.map(&:text)
extracted_urls = []
statuses.each do |status|
  urls = URI.extract status
  next if urls.size == 0
  urls.each do |url|
    scheme = URI.parse(url).scheme rescue ""
    next if scheme != "http"
    extracted_urls << url
  end
end  

#eliminate duplicates
extracted_urls.uniq!

#for i in 1..extracted_urls.size do
#  puts "#{i}. #{extracted_urls[i-1]}"
#end

i = 1
extracted_urls.each do |url|
  begin
    open(url) do |resp|
      puts "#{i}. #{resp.base_uri.to_s}"
      i += 1
    end
  rescue => e
    #puts "#{e} --- #{u}"
    #pp e.backtrace
  end
end
