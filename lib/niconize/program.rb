class Niconize
  def program(lv)
    login unless @logined
    Program.new(self, lv)
  end

  class Program
    attr_reader :lv, :vid

    def initialize(parent, lv)
      @parent = parent
      @agent = parent.agent
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

      @agent.post(URL[:reserve], data)
    end

    private

    def reserved?
      query = { 'mode' => 'list' }
      response = @agent.get(URL[:reserve], query)
      vid_list = response.search('timeshift_reserved_list').children.map { |vid_element| vid_element.inner_text }
      !!vid_list.include?(vid)
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
      response = @agent.get(URL[:reserve], query)
      raise TimeshiftError, 'It is the limit of the number of your reservation' unless response.at('div.reserve')
      response.at('div.reserve').inner_html.scan(/ulck_[0-9]+/)[0]
    end

    class TimeshiftError < StandardError; end
  end
end
