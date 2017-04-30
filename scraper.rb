#!/bin/env ruby
# encoding: utf-8
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'
# require 'scraped_page_archive/open-uri'

class MembersPage < Scraped::HTML
  field :members do
    noko.css('.MsoTableGrid tr').drop(1).map do |row|
      fragment(row => MemberRow).to_h
    end
  end
end

class MemberRow < Scraped::HTML
  field :id do
    tds[0].text.tidy
  end

  field :name do
    tds[1].text.tidy
  end

  field :area do
    tds[2].text.tidy
  end

  field :photo do
    tds[3].css('img[src*="assembleenationale"]/@src').text
  end

  field :party do
    'unknown'
  end

  field :term do
    12
  end

  private

  def tds
    noko.css('td')
  end
end

def scraper(h)
  url, klass = h.to_a.first
  klass.new(response: Scraped::Request.new(url: url).response)
end

url = 'http://www.assembleenationale.mr/index.php?option=com_content&view=article&id=352&Itemid=164&lang=en'
data = scraper(url => MembersPage).members
data.each { |r| puts r.reject { |_, v| v.to_s.empty? }.sort_by { |k, _| k }.to_h } if ENV['MORPH_DEBUG']

ScraperWiki.sqliteexecute('DROP TABLE data') rescue nil
ScraperWiki.save_sqlite(%i[name term], data)
