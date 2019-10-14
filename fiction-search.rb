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
results = search_page.css("tr td a")
puts results.to_s
puts search_page.to_s