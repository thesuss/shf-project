#!/usr/bin/ruby


#--------------------------
#
# @class CsvRow
#
# @desc Responsibility: A simple representation of a CSV row. It has an ordered
# list of elements. The :to_s representation puts a comma between each element.
#
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-03-16
#
# @file csv_row.rb
#
#--------------------------


class CsvRow

  def initialize(ordered_list_of_items = [])
    @elements = ordered_list_of_items
  end


  def append(element)
    @elements.append element
    self
  end

  alias_method :<<, :append

  def elements
    @elements ||= []
  end


  def to_s
    @elements.join(',')
  end

end # CsvRow
