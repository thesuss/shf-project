require 'rails_helper'

require File.join(Rails.root, 'db/require_all_seeders_and_helpers.rb')

require 'csv'
require 'smarter_csv'


RSpec.describe Seeders::KommunsSeeder do

  it 'creates exactly the same kommuns as are listed in the original csv file' do

    allow(described_class).to receive(:tell).and_return(false)

    kommuns_from_csv = []
    SmarterCSV.process('lib/seeds/kommuner.csv').each do |kommun|
      kommuns_from_csv << Kommun.new(name: kommun[:name])
    end

    described_class.seed
    expect(described_class::SEEDED_CLASS.all.map(&:name)).to match_array(kommuns_from_csv.map(&:name))
  end

end
