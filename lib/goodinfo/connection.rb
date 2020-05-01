require 'open-uri'

module Goodinfo
	module Connection
		def get(path, **params)
			request(path, params)
		end

		private

		def request(path, params)
			connection(path, params)
=begin
			response = connection(method, path, params)

			error = Error.from_response(response)
			raise error if error

			response.body
=end
		end

		def connection(path, params)
			@url = Filter::BASE_URL + path + params[:code]

			@charset = nil
			html = open(@url) do |f|
				@charset = f.charset
				f.read
			end

			@charset = html.scan(/charset="?([^\s"]*)/i).first.join if @charset.nil?

			html
		end
	end
end
