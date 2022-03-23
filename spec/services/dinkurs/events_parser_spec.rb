# frozen_string_literal: true

require 'rails_helper'

describe Dinkurs::EventsParser do
  let(:events_array) { build :dinkurs_events }
  let(:parsed_events) { build :events_hashes }

  subject(:events_parser) { described_class.new(events_array, 1) }

  it 'return array of items' do
    expect(events_parser.call).to be_a_kind_of(Array)
  end

  it 'return same number of items as in events_array' do
    expect(events_parser.call.count).to eq(events_array.count)
  end

  it 'properly parse data to array of hashes with needed attributes' do
    expect(events_parser.call).to match_array(parsed_events)
  end

  context 'bad or unknown format returnred by Dinkurs' do

    it 'raises error' do
      parser = described_class.new({event: 'just a string'}, 1)
      expect{parser.call}.to raise_error(Dinkurs::Errors::InvalidFormat, 'Could not get event info from: [:event, "just a string"]')
    end
  end
end
