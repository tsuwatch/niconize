# Niconize

Wrapper of mechanize for [http://www.nicovideo.jp](http://www.nicovideo.jp)

## Feature

- Login to nicovideo
- Timeshift reserve a niconico live
...and more

## Installation

    $ gem install niconize

## Usage
```ruby
require 'niconize'

client = Niconize::Client.new('YOUR_MAIL_ADDRESS', 'PASSWORD')

# timeshift reservation
client.program('lvxxxxxx').reserve
```
