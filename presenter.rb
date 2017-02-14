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
