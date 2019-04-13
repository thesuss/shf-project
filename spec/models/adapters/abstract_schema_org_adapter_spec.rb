require 'spec_helper'

ADAPTERS_PATH = File.join(__dir__, '..', '..', '..', 'app', 'models','adapters')
require File.join(ADAPTERS_PATH,'abstract_adapter')
require File.join(ADAPTERS_PATH,'abstract_schema_org_adapter')


# create a class that is 'adapted'
class FauxPlaceClass

  attr_accessor :here, :there

  def initialize(place1='Place1', place2='Place2')
    @here = place1
    @there = place2
  end


  def to_str
    "#{here}, #{there}"
  end

  # This just contrived for this test
  def ==(something)
    something.class == self.class &&
        something.to_str == self.to_str
  end

end # end faux class

Two_Strings = Struct.new(:string1, :string2) do
  def to_str
    "TwoStrings: This is string1: #{string1} and this is string2: #{string2}"
  end
end

module Adapters
  class TestAdapter < Adapters::AbstractSchemaOrgAdapter

    def target_class
      FauxPlaceClass
    end


    def set_target_attributes(target)
      target.here = @adaptee.string1
      target.there = @adaptee.string2
      target
    end
  end


  class TestSublcassMissingMethodsAdapter < Adapters::AbstractSchemaOrgAdapter
  end

end


RSpec.describe Adapters::AbstractSchemaOrgAdapter, type: :model do

  let(:test_adapter) { Adapters::TestAdapter.new(Two_Strings.new('here', 'there')) }


  it 'the target is adapted correctly' do
    expect(test_adapter.as_target.to_str).to eq "here, there"
  end


  describe 'as_target aliases for readability' do

    it 'to_schema_org' do
      expect(test_adapter.to_schema_org).to eq test_adapter.as_target
    end

    it 'to_target' do
      expect(test_adapter.to_target).to eq test_adapter.as_target
    end
  end


end
