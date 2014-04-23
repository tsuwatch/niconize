class Niconize
  def live(lv)
    login unless @logined
    Live.new(self, lv)
  end

  class Live
    attr_reader :lv

    def initialize(parent, lv)
      @parent = parent
      @agent = parent.agent
      @lv = lv
    end

    def live_page
      @live_page ||= @agent.get("http://live.nicovideo.jp/watch/#{lv}")
    end

    def reserved?
      !!live_page.search('a.watching_reservation_reserved')[0]
    end

    def token
      live_page.search('a.watching_reservation')[0]['onclick'].scan(/'(.*?)'/)[1][0]
    end

    def ulck
      lv_num = lv.sub(/^lv/, '')

      query = {
        'mode' => 'watch_num',
        'vid' => lv_num,
        'token' => token
      }
      response = @agent.get(URL[:reserve], query)
      raise TimeshiftError, 'It is the limit of the number of your reservation' unless response.at('div.reserve')
      response.at('div.reserve').inner_html.scan(/ulck_[0-9]+/)[0]
    end

    def reserve
      raise TimeshiftError, 'This nicolive is already reserved'  unless reserved?
      lv_num = lv.sub(/^lv/, '')

      data = {
        'mode' => 'regist',
        'vid' => lv_num,
        'token' => ulck,
        '_' => ''
      }

      @agent.post(URL[:reserve], data)
    end

    class TimeshiftError < StandardError; end
  end
end
