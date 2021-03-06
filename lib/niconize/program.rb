module Niconize
  class Program
    class TimeshiftError < StandardError; end

    attr_reader :lv, :vid

    def initialize(client, lv)
      @client = client
      @agent = client.agent
      @lv = lv
      @vid = lv.sub(/^lv/, '')
    end

    def reserve
      raise TimeshiftError, 'This nicolive is already reserved' if reserved?

      data = {
        'mode' => 'regist',
        'vid' => vid,
        'token' => ulck,
        '_' => ''
      }

      @agent.post(Niconize::Client::URL[:reserve], data)
    end

    private

    def reserved?
      !!@client.reserved_programs.map { |program| program.vid }.include?(vid)
    end

    def live_page
      @live_page ||= @agent.get("http://live.nicovideo.jp/watch/#{lv}")
    end

    def token
      live_page.search('a.watching_reservation')[0]['onclick'].scan(/'(.*?)'/)[1][0]
    end

    def ulck
      query = {
        'mode' => 'watch_num',
        'vid' => vid,
        'token' => token
      }
      response = @agent.get(Niconize::Client::URL[:reserve], query)
      raise TimeshiftError, 'It is the limit of the number of your reservation' unless response.at('div.reserve')
      response.at('div.reserve').inner_html.scan(/ulck_[0-9]+/)[0]
    end
  end
end
