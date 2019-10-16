#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'optparse'

# http://gen.lib.rus.ec/fiction/?q=watership+down&criteria=title&language=English&format=mobi
crit = ""
wildcard = ""
lang = "English"
form = "mobi"
OptionParser.new do |o|
	o.banner = ""
	o.on("-a","--crit-author", "search by author") do |a|
		crit = "authors"
	end
	o.on("-t","--crit-title", "search by title") do |a|
		crit = "title"
	end
	o.on("-s","--crit-series", "search by series") do |a|
		crit = "series"
	end
	o.on("-A","--crit-any", "search by any of author, title, or series") do |a|
		crit = ""
	end	
	o.on("-w","--wildcard","Search with wildcard") do |a|
		wildcard = "&wildcard=1"
	end
	o.on("-l","--language LANGUAGE", "Language of title (default English)") do |l|
		lang = l
	end
	o.on("-f","--format FORMAT", "Format to search for (default mobi") do |f|
		form = f
	end
end.parse!
query = ARGV.join("+")
@url = "http://gen.lib.rus.ec/fiction/?q=#{query}&criteria=#{crit}#{wildcard}&language=#{lang}&format=#{form}"
search_page = Nokogiri::HTML(open(@url))
results = {}
results[:titles] = []
results[:authors] = []
results[:files] = []
links = search_page.css("tr td a")
links.each do |c|
	unless results[:titles].include?(c.content)
		results[:titles] << c.content unless ( c.content[0] == "[" and c.content[2] == "]" ) or c.keys.include?("title")
		results[:authors] << c.content if c["title"].include?("search") if c.keys.include?("title")
		tmpfile = c["href"] if c.content == "[1]"
		if tmpfile.class == String
			doc = Nokogiri::HTML(open(tmpfile))
			results[:files] << "http://#{tmpfile.split("/")[2]}#{doc.css("a").first["href"]}"
		end
	end
end
puts "Saving first of each unique title matching search:"
for ii in 0..results[:titles].length-1
	puts "#{results[:authors][ii]}	#{results[:titles][ii]}"
	fname = "#{results[:titles][ii].gsub(" ","_")}.#{form}"
	File.open(fname, "wb") do |local_f|
		open(results[:files][ii], 'rb') do |remote_f|
			local_f.write(remote_f.read)
		end
	end
end