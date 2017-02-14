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
