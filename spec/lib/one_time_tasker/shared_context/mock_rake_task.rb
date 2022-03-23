#--------------------------
#
# @class MockRakeTask
#
# @desc Responsibility: act as a mock for a Rake::Task.  Stubs methods
#
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2019-06-04
#
# @file MockRakeTask
#
#--------------------------


class MockRakeTask

  attr_accessor :name

  def initialize(name = 'mock task')
    @name = name
  end


  def self.reenable

  end


  def self.invoke

  end


  def reenable

  end


  def invoke

  end

end
