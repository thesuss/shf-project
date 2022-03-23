require 'spec_helper'
require File.join(__dir__, '..', '..', '..', 'app', 'models','adapters','abstract_adapter')


# Faux class that is 'adapted' (@adaptee is converted/adapted to an integer)
class FauxIntegerClass

  attr_accessor :my_int

  def initialize(initial_int = 0)
    @my_int = initial_int
  end

  def to_s
    my_int.to_s
  end


  # This just contrived for this test
  def ==(something)
    something.class == self.class &&
        something.to_s == self.to_s
  end

end # FauxIntegerClass


# 'adapt' a string to an integer
class TestAdapter < Adapters::AbstractAdapter

  def target_class
    FauxIntegerClass
  end

  def set_target_attributes(target)
    target.my_int = @adaptee.to_s.to_i
  end

end


class TestSublcassMissingMethodsAdapter < Adapters::AbstractAdapter
end


RSpec.describe Adapters::AbstractAdapter, type: :model do

  let(:test_adapter) { TestAdapter.new('501') }
  let(:as_target_result) { test_adapter.as_target }

  let(:test_bad_adapter) { TestSublcassMissingMethodsAdapter.new('some string') }


  it 'adapter cannot be nil' do
    expect { TestAdapter.new(nil) }.to raise_exception ArgumentError
    expect(TestAdapter.new('some string')).to be_a(TestAdapter)
  end


  describe 'target_class' do

    it "subclasses must implement; raises NoMethodError if they don't" do
      expect { test_bad_adapter.target_class }.to raise_exception NoMethodError
    end

  end

  describe 'set_target_attributes' do

    it "subclasses must implement; raises NoMethodError if they don't" do
      expect { test_bad_adapter.set_target_attributes('blorf') }.to raise_exception NoMethodError
    end
  end


  describe 'as_target' do

    it 'calls target_class' do
      expect(test_adapter).to receive(:target_class)
                                  .and_call_original
      test_adapter.as_target
    end


    it 'calls set_target_attributes with an instance of the target_class' do
      expect(test_adapter).to receive(:set_target_attributes)
                                  .with(kind_of(test_adapter.target_class))
                                  .and_call_original
      test_adapter.as_target
    end

  end

  it 'the target result is correct' do
    expect(as_target_result).to eq 501
  end


  describe 'as_target aliases for readability' do

    it 'to_target' do
      expect(test_adapter.to_target).to eq as_target_result
    end
  end

end
