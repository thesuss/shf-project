require 'rails_helper'

RSpec.describe CompanyLocator, type: :model do


  before(:each) do

    create(:company,
           name:           'Stockholm Co',
           street_address: 'Rehnsgatan 15',
           post_code:      '113 57',
           city:           'Stockholm')

    create(:company, name: 'Stockholm Co2',
           street_address: 'Celsiusgatan 6',
           post_code:      '112 30',
           city:           'Stockholm')

    create(:company,
           name:           'Kista Co',
           street_address: 'AKALLALÄNKEN 10',
           post_code:      '164 74',
           city: 'Kista')


    create(:company, name: 'Årsta Co',
           street_address: 'Svärdlångsvägen 11 C',
           post_code:      '120 60',
           city:           'Årsta')

    create(:company, name: 'Lidingö Co',
           street_address: 'Bodalsvägen 15',
           post_code:      '181 36',
           city:           'Lidingö')

    create(:company, name: 'Bromma Co1',
           street_address: 'Ulvsundavägen 146',
           post_code:      '167 68',
           city:           'Bromma')

  end

  describe '.find_near_coordinates' do

    # 59.3251172, 18.0710935 = Stockholm
    # 47.6038321, -122.3300624 = Seattle

    let(:stockholm_lat) { 59.3251172 }
    let(:stockholm_long) { 18.0710935 }

    it 'returns an array of Addresses' do
      result = described_class.find_near_coordinates(stockholm_lat, stockholm_long)
      expect(result).to be_a Array
      expect(result.first).to be_a Address
    end

    it 'real coordinates 59.3251172, -122.3300624' do
      expect(described_class.find_near_coordinates(stockholm_lat, stockholm_long).size).to eq 5
    end

    it 'default distance is 10 km' do
      expect(described_class.find_near_coordinates(stockholm_lat, stockholm_long).size).to eq 5
    end

    it 'uses default distance if distance is nil' do
      expect(described_class.find_near_coordinates(stockholm_lat, stockholm_long, nil).size).to eq 5
    end

    it 'can use distance other than default' do
      expect(described_class.find_near_coordinates(stockholm_lat, stockholm_long, 100).size).to eq 6
    end

    context 'bad arguments' do

      it 'nil latitude raises ArgumentError' do
        expect { described_class.find_near_coordinates(nil, stockholm_long) }.to raise_error ArgumentError, I18n.t('company_locator.error.latitude_blank')
      end

      it 'nil longitude raises ArgumentError' do
        expect { described_class.find_near_coordinates(stockholm_lat, nil) }.to raise_error ArgumentError, I18n.t('company_locator.error.longitude_blank')
      end

      it 'negative distance raises ArgumentError' do
        expect { described_class.find_near_coordinates(stockholm_lat, stockholm_long, -50) }.to raise_error ArgumentError, I18n.t('company_locator.error.search_distance_negative')
      end

    end
  end

  describe '.find_near_name' do


    it 'returns an array of Addresses' do
      result = described_class.find_near_name('Stockholm')
      expect(result).to be_a Array
      expect(result.first).to be_a Address
    end

    it 'real city (Stockholm)' do
      expect(described_class.find_near_name('Stockholm').size).to eq 5
      # distance and bearing exist in each array item even though they don't print out!
    end

    it 'fake location (not found) returns empty list' do
      expect(described_class.find_near_name('fakeCity', 10).size).to eq 0
    end

    it 'default distance is 10km' do
      expect(described_class.find_near_name('Stockholm').size).to eq 5
    end

    it 'uses the default distance if distance == nil (makes it easier with CompaniesController)' do
      expect(described_class.find_near_name('Stockholm', nil).size).to eq 5
    end

    it 'can enter a distance other than the default' do
      expect(described_class.find_near_name('Stockholm', 20).size).to eq 6
    end

    it 'uses the default country if country == nil (makes it easier with CompaniesController to build a query)' do
      expect(described_class.find_near_name('Stockholm', nil, country: nil).size).to eq 5
    end

    describe 'sanitizes the name string' do

      it ".near('<script>something bad happens</script>') is sanitized to a blank string" do
        expect { described_class.find_near_name('<script>something bad happens</script>') }.to raise_error ArgumentError, I18n.t('company_locator.error.search_name_blank')
      end

      it ".near('<script>something bad happens</script>Stockholm') is sanitized to just 'Stockholm'" do
        expect(described_class.find_near_name('<script>something bad happens</script>Stockholm').size).to eq 5
      end
    end

    context 'bad arguments' do

      it 'blank name raises ArgumentError' do
        expect { described_class.find_near_name('', 10) }.to raise_error ArgumentError, I18n.t('company_locator.error.search_name_blank')
      end

      it 'negative distance raises ArgumentError' do
        expect { described_class.find_near_name('Stockholm', -0.1) }.to raise_error ArgumentError, I18n.t('company_locator.error.search_distance_negative')
      end

    end

  end

end
