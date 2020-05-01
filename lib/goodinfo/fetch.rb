#require 'goodinfo/fetch/stock_bz_performance'
#require 'goodinfo/fetch/stock_dividend_policy'
require File.dirname(File.realpath(__FILE__)) + '/fetch/stock_bz_performance'
require File.dirname(File.realpath(__FILE__)) + '/fetch/stock_dividend_policy'

require 'nokogiri'

module Goodinfo
	module Fetch
		include StockBzPerformance
		include StockDividendPolicy

		private

		def parse query:, html:
			doc = Nokogiri::HTML.parse(html, nil, @charset)
			# => Nokogiri::HTML::Document

			case query
			when :stock_bz_performance then id = 'divFinDetail'
			when :stock_dividend_policy then id = 'divDetail'
			end

			nodes = doc.xpath("//div[@id='#{id}']/table[@class='solid_1_padding_4_0_tbl']")
			# => Nokogiri::XML::NodeSet

			raise InformationNotFound if nodes.empty?
			raise XMLNodeSetError unless nodes.length.is_one?

			node = nodes.first
			# => Nokogiri::XML::Element

			list = []
			header = []

			node.children.each do |element|
				case element.name
				when 'thead'
					header = parse_thead(query: query, element: element)
					# => ["year", nil, nil, "cash_dividend", nil, nil, "stock_dividend", "total_dividend", nil, nil, nil, nil, nil, nil, nil, nil, "cash_dividend_yield", "stock_dividend_yield", "total_dividend_yield", nil, nil, nil, nil, nil]
				when 'tr'
					value = parse_tr(query: query, row: header, element: element)
					# => {:year=>2020.0, :cash_dividend=>4.5, :stock_dividend=>0.0, :total_dividend=>4.5, :cash_dividend_yield=>7.18, :stock_dividend_yield=>0.0, :total_dividend_yield=>7.18}
					list.push value unless value.empty?
				else
					raise TableFormatError
				end
			end

			list
		end

		def parse_thead query:, element:
			header = Hash.new { |h, k| h[k] = {} }
=begin
			element.children.each_with_index do |sub_element, idx|
				case idx
				when 0
				when 1
					col = 0
					sub_element.children.each do |e|
						next unless e.element?

						header[:year] = col if e.child.child.text == '股利發放年度'

						col = col.succ
					end
				when 2
					sub_element.children.each{ |e|
						next unless e.element?

						header[:dividend][:cash] = nil if e.child.child.text == '現金股利'
						header[:dividend][:stock] = nil if e.child.child.text == '股票股利'
						header[:dividend][:total] = nil if e.child.child.text == '股利' # 股利合計
						header[:dividend_yield][:total] = header[:dividend_yield][:cash] = header[:dividend_yield][:stock] = nil if e.child.child.text == '年均殖利率(%)'
					}
				when 3
				else
					raise TableHeaderError
				end
			end
=end
#=begin
			case query
			when :stock_bz_performance
				header = [
					'year', # 年度
					nil, # 股本(億)
					nil, # 財報評分
					nil, nil, nil, nil, # 年度股價(元)
					'net_sales', 'gross_profit', 'operating_income', nil, nil, # 獲利金額(億)
					'gross_profit_margin', 'operating_profit_margin', nil, nil, # 獲利率(%)
					'roe', # ROE(%)
					'roa', # ROA(%)
					'eps', 'eps_year_on_year', # EPS(元)
					'bps' # BPS(元)
				]
			when :stock_dividend_policy
				header = [
					'year',
					nil, nil, 'cash_dividend',
					nil, nil, 'stock_dividend',
					'total_dividend',
					nil, nil, nil, nil,
					nil, nil, nil, nil,
					'cash_dividend_yield', 'stock_dividend_yield', 'total_dividend_yield', 
					nil, 'eps', nil, nil, nil
				]
				# reference
				# => {:year => 0, :dividend => {:cash => 3, :stock => 6, :total => 7}, :dividend_yield => {:cash => 16, :stock => 17, :total => 18}}
			end
#=end

			header
		end

		def parse_tr query:, row:, element:
			hash = Hash.new

			col = 0
			element.children.each do |e|
				next unless e.element?

				if col.is_zero? and e.child.child.text == '累計'
					hash = Hash.new
					break
				end

				case query
				when :stock_bz_performance then value = col.is_zero? ? e.child.child.text : e.child.text
				when :stock_dividend_policy then value = col.is_zero? ? e.child.child.child.text : e.child.text
				end

				unless row[col].nil?
					if value.is_currency?
						hash[row[col].to_sym] = col.is_zero? ? value.to_currency.to_i : value.to_currency
					elsif value == '-'
						hash[row[col].to_sym] = value
					else
						raise TableBodyError
					end
				end

				col = col.succ
			end

			hash
		end
	end
end

class Integer
	def is_zero?
		self == 0
	end

	def is_one?
		self == 1
	end
end

class String
	def is_currency?
		(self =~ /^[+-]?[0-9]*[\,]?[0-9]*[\.]?[0-9]+$/).nil? ? false : true
	end

	def to_currency
		unless self.is_currency?
			STDERR.puts "#{__FILE__}:#{__LINE__}: argument - #{self}"
			raise ArgumentError
		end

		self.gsub(/[\,]/, '').to_f
	end
end
