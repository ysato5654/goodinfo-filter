#require 'goodinfo/connection'
#require 'goodinfo/fetch'
require File.dirname(File.realpath(__FILE__)) + '/connection'
require File.dirname(File.realpath(__FILE__)) + '/fetch'

module Goodinfo
	class Filter
		include Connection
		include Fetch

		BASE_URL = 'https://goodinfo.tw'

		def initialize
		end
	end
end
