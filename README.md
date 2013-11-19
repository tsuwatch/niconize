# Niconize

Wrapper of mechanize for [http://www.nicovideo.jp](http://www.nicovideo.jp)

## Feature

- Login to nicovideo
- Timeshift reserve a niconico live

## Installation

    $ gem install niconize

## Usage
```ruby
require 'niconize'

niconize = Niconize.new('YOUR_MAIL_ADDRESS', 'PASSWORD')

# timeshift reservation
niconize.reserve('lvxxxxxx')
```
