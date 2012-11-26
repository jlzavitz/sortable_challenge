#!/bin/env ruby
# encoding: utf-8
require "json"

garbage_keys = [ 'für\ ', 'with\ ','for\ ', 'avec\ ', '\:', '\+', '\&', 'w\/', 'de\ ' 'sur\ ', 'à\ ', 'in[c|k]\ ', 'in[c|k]l\ ', 'in[c|k]l\.', 'in[c|k]\.' ]

# translate files to valid json format
def fileToJSON(filename)
	File.open(filename) do |file|
		JSON.parse("[#{file.readlines.join(",")}]")
	end
end

# trim listings based on ending with any garbage_keyword
# this creates a variant of the title that is used to search in
# it chops off any additions after (ex. camera WITH lens ...
# this decreases false positives that may match additional information other than product
# also concatenates manufacturer name in case it was not in title
# ie. Camera 12.1 mp + extra bright ... => Camera 12.1 mp
def chop_listings(listings, keys)
	listings.map{|lst| lst["title"].downcase.sub(/#{keys.join('.*|\ ')}.*/, "").strip.concat(" " + lst["manufacturer"]).downcase.strip}
end


listings = fileToJSON("challenge_data_20110429/listings.txt")
products = fileToJSON("challenge_data_20110429/products.txt")
trimmed_listings = chop_listings(listings, garbage_keys)

# file to write results into
f = File.open("results.txt", 'w')
 

#main loop testing for matches based on chopped string and product name
products.each do |p|
	keywords = p["product_name"].downcase.split(/\W|_/)
	count = keywords.size
	matched_size = 0;
	index = 0;
	f.write("{\"product_name\":" + "\"" + p["product_name"] + "\", \"listings\":[")
	trimmed_listings.each do |l|
		matched_keys = 0
		keywords.each do |k|
			matched_keys += l.include?(k)? 1 : 0 
		end
		if (matched_keys/count ==1) then
			if(matched_size != 0)
				f.write(",")
			end
			f.write("#{listings[index].to_s.gsub("\=\>",":")}")
			listings.delete_at(index)
			trimmed_listings.delete_at(index);
			matched_size = 1
		end
		index+=1;
	end
	f.write("]}\n")
	
end
 





