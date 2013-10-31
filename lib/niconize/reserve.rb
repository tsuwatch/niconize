class Niconize
  def reserve(lv)
    login unless @logined
    query = get_query(lv)
    q = query.scan(/'(.*?)'/)
    ulck = get_ulck(q[0][0], q[1][0])
    response = do_reservation(lv, ulck)
  end

  def get_query(lv)
    login unless @logined
    response = @agent.get("http://live.nicovideo.jp/watch/#{lv}")

    response.search('a.watching_reservation')[0]['onclick']
  end

  def get_ulck(lv, token)
    login unless @logined
    lv = lv.sub(/^lv/, '')

    query = {
      'mode' => 'watch_num',
      'vid' => lv,
      'token' => token
    }
    response = @agent.get(URL[:reserve], query)
    raise UlckParseError, 'It is the limit of the number of your reservation' unless response.at('div.reserve')
    response.at('div.reserve').inner_html.scan(/ulck_[0-9]+/)[0]
  end

  def do_reservation(lv, ulck)
    login unless @logined
    lv = lv.sub(/^lv/, '')

    data = {
      'mode' => 'regist',
      'vid' => lv,
      'token' => ulck,
      '_' => ''
    }

    response = @agent.post(URL[:reserve], data)
  end

  class UlckParseError < StandardError; end
end
