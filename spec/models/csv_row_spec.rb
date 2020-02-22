require File.absolute_path( File.join(__dir__, '..', '..', 'app','models', 'csv_row') )

require 'spec_helper'


RSpec.describe CsvRow do

  describe 'to_s' do

    it 'returns empty String if empty' do
      expect(subject.to_s).to eq ''
    end

    it 'one element = the .to_s for that element' do
      new_row = described_class.new([100])
      expect(new_row.to_s).to eq '100'
    end

    it 'is the .to_s for that element' do
      new_row = described_class.new([''])
      expect(new_row.to_s).to eq ''
    end

  end


  describe 'append' do

    it 'adds the element at the end' do
      new_row = described_class.new([1, 2])
      new_row.append 3
      expect(new_row.to_s).to eq '1,2,3'
    end
  end


  it '<< is an alias for append' do
    new_row = described_class.new([1, 2])
    new_row << 3
    expect(new_row.to_s).to eq '1,2,3'
  end


  describe 'append_items' do

    it 'adds all of the elements in the given array  at the end' do
      new_row = described_class.new([1, 2])
      new_row.append_items [3, 4]
      expect(new_row.to_s).to eq '1,2,3,4'
    end

  end

  it 'concat is an alias for append_items' do
    new_row = described_class.new([1, 2])
    new_row.concat [3, 4]
    expect(new_row.to_s).to eq '1,2,3,4'
  end
end
