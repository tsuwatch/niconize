require_relative './program'

class Niconize
  def live
    login unless @logined
    @live ||= Live.new(self)
  end

  class Live
    def initialize(parent)
      @parent = parent
      @agent = parent.agent
    end

    def reserved_programs
      query = { 'mode' => 'list' }
      response = @agent.get(URL[:reserve], query)
      response.search('timeshift_reserved_list').children.map { |vid_element| Program.new(@parent, 'lv' + vid_element.inner_text) }
    end
  end
end
