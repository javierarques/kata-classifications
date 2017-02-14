class Parser
  def initialize(json)
    @json = json
  end

  def parse
    JSON.parse(@json)['classification']
  end
end
