#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'
# require 'scraped_page_archive/open-uri'

def noko_for(url)
  Nokogiri::HTML(open(url).read)
end

def scrape_list(url)
  noko = noko_for(url)
  noko.css('.MsoTableGrid tr').drop(1).each do |row|
    tds = row.css('td')
    data = {
      id:    tds[0].text.tidy,
      name:  tds[1].text.tidy,
      area:  tds[2].text.tidy,
      photo: tds[3].css('img[src*="assembleenationale"]/@src').text,
      party: 'unknown',
      term:  12,
      # source: url,
    }
    # puts data
    ScraperWiki.save_sqlite(%i[name term], data)
  end
end

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
scrape_list('http://www.assembleenationale.mr/index.php?option=com_content&view=article&id=352&Itemid=164&lang=en')
