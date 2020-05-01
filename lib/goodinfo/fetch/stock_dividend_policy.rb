module Goodinfo
	module Fetch
		module StockDividendPolicy
			def stock_dividend_policy(code)
				parse(query: __method__, html: get('/StockInfo/StockDividendPolicy.asp?STOCK_ID=', code: code))
			end
		end
	end
end
