require 'rails_helper'

require File.join(Rails.root, 'db/require_all_seeders_and_helpers.rb')

require 'csv'
require 'smarter_csv'


RSpec.describe Seeders::RegionsSeeder do


  describe '.load_from_city_state_gem' do

    it 'calls the city-state gem to load regions for :se ("states")' do
      expect(CS).to receive(:states).with(:se).and_return({})
      described_class.load_from_city_state_gem
    end

    it 'creates new Regions with a name and iso code' do
      expect(described_class::SEEDED_CLASS.count).to eq 0
      expect{described_class.load_from_city_state_gem}.to change(described_class::SEEDED_CLASS, :count)
    end
  end


  describe '.create_sverige_and_online_regions' do

    it "creates 2 #{described_class::SEEDED_CLASS}s" do
      expect{ described_class.create_sverige_and_online_regions }.to change(described_class::SEEDED_CLASS, :count).by(2)
    end

    it 'creates the "Sverige" Region' do
      expect(described_class::SEEDED_CLASS.find_by(name: 'Sverige')).to be_nil
      described_class.create_sverige_and_online_regions
      expect(described_class::SEEDED_CLASS.find_by(name: 'Sverige')).not_to be_nil
    end

    it 'creates the "Online" Region' do
      expect(described_class::SEEDED_CLASS.find_by(name: 'Online')).to be_nil
      described_class.create_sverige_and_online_regions
      expect(described_class::SEEDED_CLASS.find_by(name: 'Online')).not_to be_nil
    end
  end

end
