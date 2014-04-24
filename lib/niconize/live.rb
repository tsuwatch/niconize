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

    def reserve
      raise TimeshiftError, 'This nicolive is already reserved' if reserved?
      lv_num = lv.sub(/^lv/, '')

      data = {
        'mode' => 'regist',
        'vid' => lv_num,
        'token' => ulck,
        '_' => ''
      }

      @agent.post(URL[:reserve], data)
    end

    private

    def reserved?
      lv_num = lv.sub(/^lv/, '')
      query = { 'mode' => 'list' }
      response = @agent.get(URL[:reserve], query)
      vid_list = response.search('timeshift_reserved_list').children.map { |vid| vid.inner_text }
      !!vid_list.include?(lv_num)
    end

    def live_page
      @live_page ||= @agent.get("http://live.nicovideo.jp/watch/#{lv}")
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

    class TimeshiftError < StandardError; end
  end
end
