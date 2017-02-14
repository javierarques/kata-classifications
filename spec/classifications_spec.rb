require 'rspec'
require 'net/https'
require 'uri'
require 'json'

require_relative '../parser'
require_relative '../presenter'
require_relative '../sorter'
require_relative '../fetcher'

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock # or :fakeweb
end

class Ranker
  URL = 'https://classification-kata.herokuapp.com/'.freeze

  def call
    json = Fetcher.new(URL).call
    parsed_json = Parser.new(json).parse
    sorted_list = Sorter.new(parsed_json).sort
    Presenter.new(sorted_list).present
  end
end

describe 'Integration test' do
  it 'gives sorted list' do
    VCR.use_cassette("fetcher") do
      ranker = Ranker.new

      result = ranker.call

      expect(result).to eq("indice | ciudad | puntos
1 | Valencia | 10
2 | Bilbao | 9
3 | Zaragoza | 8
4 | Barcelona | 7
5 | Madrid | 5")
    end
  end
end

describe 'Classification kata' do
  it 'get the JSON parsed' do
    # #Arrange
    path = File.expand_path("./fixtures/classification.json", File.dirname(__FILE__))
    some_json = File.read(path)
    parser = Parser.new(some_json)

    # #Act
    parsed_response = parser.parse

    # #Asserst
    expect(parsed_response).to eq([
                                    { 'name' => 'Madrid', 'points' => 5 },
                                    { 'name' => 'Valencia', 'points' => 10 },
                                    { 'name' => 'Barcelona', 'points' => 7 },
                                    { 'name' => 'Zaragoza', 'points' => 8 },
                                    { 'name' => 'Bilbao', 'points' => 9 }
                                  ])
  end

  it 'sorts object by points' do
    list = [
      { 'name' => 'Madrid', 'points' => 5 },
      { 'name' => 'Valencia', 'points' => 10 },
      { 'name' => 'Barcelona', 'points' => 7 }
    ]
    sorted_list = [
      { 'name' => 'Valencia', 'points' => 10 },
      { 'name' => 'Barcelona', 'points' => 7 },
      { 'name' => 'Madrid', 'points' => 5 }
    ]
    sorter = Sorter.new(list)

    sorted = sorter.sort

    expect(sorted).to eq(sorted_list)
  end

  it 'converts into text the given object' do
    cities = [
      { 'name' => 'Valencia', 'points' => 10 },
      { 'name' => 'Bilbao', 'points' => 9 },
      { 'name' => 'Zaragoza', 'points' => 8 },
      { 'name' => 'Barcelona', 'points' => 7 },
      { 'name' => 'Madrid', 'points' => 5 }
    ]

    presenter = Presenter.new(cities)
    presented = presenter.present

    expect(presented).to eq("indice | ciudad | puntos
1 | Valencia | 10
2 | Bilbao | 9
3 | Zaragoza | 8
4 | Barcelona | 7
5 | Madrid | 5")
  end

  it 'gets some json from an url' do
    VCR.use_cassette("fetcher") do
      url = 'https://classification-kata.herokuapp.com/'
      fetcher = Fetcher.new(url)
      some_json = '{"classification":[{"name":"Madrid","points":5},{"name":"Valencia","points":10},{"name":"Barcelona","points":7},{"name":"Zaragoza","points":8},{"name":"Bilbao","points":9}]}'

      result = fetcher.call

      expect(result).to eq(some_json)
    end
  end
end
