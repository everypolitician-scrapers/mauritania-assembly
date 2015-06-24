#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.MsoTableGrid tr').drop(1).each do |row|
    tds = row.css('td')
    data = { 
      id: tds[0].text.strip,
      name: tds[1].text.strip,
      area: tds[2].text.strip,
      photo: tds[3].css('img[src*="assembleenationale"]/@src').text,
      party: "unknown",
      term: 12,
      #source: url,
    }
    puts data
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

term = {
  id: 12,
  name: '12th National Assembly',
  start_date: '2013-12-21',
}
ScraperWiki.save_sqlite([:id], term, 'terms')

scrape_list('http://www.assembleenationale.mr/index.php?option=com_content&view=article&id=352&Itemid=164&lang=en')
