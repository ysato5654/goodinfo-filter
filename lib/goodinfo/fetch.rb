#require 'goodinfo/fetch/stock_dividend_policy'
require File.dirname(File.realpath(__FILE__)) + '/fetch/stock_dividend_policy'

require 'nokogiri'

module Goodinfo
	module Fetch
		include StockDividendPolicy
	end
end
