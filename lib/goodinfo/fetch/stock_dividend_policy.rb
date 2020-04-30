module Goodinfo
	module Fetch
		module StockDividendPolicy
			def stock_dividend_policy(code)
				parse(get('/StockInfo/StockDividendPolicy.asp?STOCK_ID=', code: code))
			end

			private

			def parse html
				doc = Nokogiri::HTML.parse(html, nil, @charset)
				# => Nokogiri::HTML::Document

				nodes = doc.xpath('//div[@id="divDetail"]/table[@class="solid_1_padding_4_0_tbl"]')
				# => Nokogiri::XML::NodeSet

				raise InformationNotFound if nodes.empty?

				raise XMLNodeSetError unless nodes.length == 1

				node = nodes.first
				# => Nokogiri::XML::Element

				list = []
				header = []

				node.children.each do |element|
					case element.name
					when 'thead'
						header = parse_thead(:element => element)
						# => ["year", nil, nil, "cash_dividend", nil, nil, "stock_dividend", "total_dividend", nil, nil, nil, nil, nil, nil, nil, nil, "cash_dividend_yield", "stock_dividend_yield", "total_dividend_yield", nil, nil, nil, nil, nil]
					when 'tr'
						value = parse_tr(:column => header, :element => element)
						# => {:year=>2020.0, :cash_dividend=>4.5, :stock_dividend=>0.0, :total_dividend=>4.5, :cash_dividend_yield=>7.18, :stock_dividend_yield=>0.0, :total_dividend_yield=>7.18}

						list.push value unless value.empty?
					else
						raise TableFormatError
					end
				end

				list
			end

			def parse_thead element:
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
				header = [
					'year',
					nil, nil, 'cash_dividend',
					nil, nil, 'stock_dividend',
					'total_dividend',
					nil, nil, nil, nil,
					nil, nil, nil, nil,
					'cash_dividend_yield', 'stock_dividend_yield', 'total_dividend_yield', 
					nil, nil, nil, nil, nil
				]
				# reference
				# => {:year => 0, :dividend => {:cash => 3, :stock => 6, :total => 7}, :dividend_yield => {:cash => 16, :stock => 17, :total => 18}}
#=end
				header
			end

			def parse_tr column:, element:
				hash = Hash.new

				col = 0
				element.children.each do |e|
					next unless e.element?

					if (col == 0) and e.child.child.text == '累計'
						hash = Hash.new
						break
					end

					value = (col == 0) ? e.child.child.child.text : e.child.text

					unless column[col].nil?
						if value == '-'
							hash[column[col].to_sym] = value
						elsif value =~ /^[+-]?[0-9]*[\.]?[0-9]+$/
							hash[column[col].to_sym] = (col == 0) ? value.to_i : value.to_f
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
end
