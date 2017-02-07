require 'rspec'
require 'net/https'
require 'uri'
require 'json'

describe 'Classification kata' do
  it 'get the JSON parsed' do
    # #Arrange
    some_json = '{"classification":[{"name":"Madrid","points":5},{"name":"Valencia","points":10},{"name":"Barcelona","points":7},{"name":"Zaragoza","points":8},{"name":"Bilbao","points":9}]}'
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
end

class Parser
  def initialize(json)
    @json = json
  end

  def parse
    JSON.parse(@json)['classification']
  end
end

class Sorter
  def initialize(list)
    @list = list
  end

  def sort
    @list.sort do |x, y|
      y['points'] <=> x['points']
    end
  end
end

class Presenter
  def initialize(list)
    @list = list
  end

  def present
    header = "indice | ciudad | puntos\n"

    output = @list.map.with_index do |item, index|
      "#{index + 1} | #{item['name']} | #{item['points']}"
    end

    header + output.join("\n")
  end
end

def parsed_response_arrr
  url = 'https://classification-kata.herokuapp.com/'
  response = get(url)

  JSON.parse(response)
end

def get(url)
  uri = URI(url)

  Net::HTTP.get(uri)
end
