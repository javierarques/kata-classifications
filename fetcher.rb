class Fetcher
  def initialize(url)
    @url = url
  end

  def call
    uri = URI(@url)
    Net::HTTP.get(uri)
  end
end
