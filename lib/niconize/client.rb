module Niconize
  class Client
    class LoginError < StandardError; end

    URL = {
      login: 'https://secure.nicovideo.jp/secure/login?site=niconico',
      live_watch: 'http://live.nicovideo.jp/watch/',
      reserve: 'http://live.nicovideo.jp/api/watchingreservation'
    }

    attr_reader :agent, :logined

    def initialize(mail, password)
      @mail = mail
      @password = password

      @logined = false

      @agent = Mechanize.new
      @agent.ssl_version = 'SSLv3'
      @agent.request_headers = {
        'accept-language' => 'ja, ja-JP'
      }
    end

    def login
      page = @agent.post(URL[:login], 'mail' => @mail, 'password' => @password)

      raise LoginError, 'Failed to login (x-niconico-authflag is 0)' if page.header['x-niconico-authflag'] == '0'
      @logined = true
    end

    def program(lv)
      login unless logined
      Niconize::Program.new(self, lv)
    end

    def reserved_programs
      query = { 'mode' => 'list' }
      response = agent.get(URL[:reserve], query)
      response.search('timeshift_reserved_list').children.map { |vid_element| Niconize::Program.new(self, 'lv' + vid_element.inner_text) }
    end
  end
end
