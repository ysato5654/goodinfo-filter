# goodinfo-filter

[Goodinfo!台灣股市資訊網](https://goodinfo.tw/) filter by Ruby

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'goodinfo-filter'
```

And then execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install goodinfo-filter
```

## Usage

```rb
goodinfo = Goodinfo::Filter.new
goodinfo.stock_dividend_policy('2331') # TSMC
```
