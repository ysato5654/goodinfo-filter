module Goodinfo
	module Fetch
		module StockBzPerformance
			def stock_bz_performance(code)
				parse(query: __method__, html: get('/StockInfo/StockBzPerformance.asp?STOCK_ID=', code: code))
			end
		end
	end
end
