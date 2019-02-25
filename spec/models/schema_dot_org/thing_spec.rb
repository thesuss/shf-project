require 'rails_helper'


RSpec.describe SchemaDotOrg::Thing, type: :model do

  let(:thing1) {
    thing             = described_class.new
    thing.name        = 'thing1'
    thing.description = 'description1'
    thing.url         = 'https:/thing1/'
    thing
  }


  describe 'validations' do
    it { is_expected.to(validate_presence_of :name) }
  end


  describe '_to_json_struct' do

    it 'values for all attributes' do
      expect(thing1._to_json_struct).to eq({ "@type"       => "Thing",
                                             'description' => 'description1',
                                             'name'        => 'thing1',
                                             'url'         => 'https:/thing1/' })
    end

    describe 'does not include entries if value is nil' do

      it 'name is nil' do
        thing1.name = nil
        expect(thing1._to_json_struct).to eq({ "@type"       => "Thing",
                                               'description' => 'description1',
                                               'url'         => 'https:/thing1/' })
      end

      it 'everything is nil' do
        thing1.name        = nil
        thing1.description = nil
        thing1.url         = nil
        expect(thing1._to_json_struct).to eq({ "@type" => "Thing" })
      end
    end


    describe 'sends .to_json_struct to get the value if an item responds to :to_json_struct' do
      pending
    end

    describe 'loops thru lists' do
      pending
    end

  end


  # This test isn't necessary.  But it's good to know it all works.
  describe 'to_ld_json' do

    it 'values for all attributes' do
      expect(thing1.to_ld_json).to eq "<script type=\"application/ld+json\">\n{" +
                                          "\"@context\":\"http://schema.org\"," +
                                          "\"@type\":\"Thing\"," +
                                          "\"@id\":\"https:/thing1/\"," +
                                          "\"name\":\"thing1\"," +
                                          "\"description\":\"description1\"," +
                                          "\"url\":\"https:/thing1/\"" +
                                          "}\n</script>"
    end

    it 'name is nil' do
      thing1.name = nil
      expect(thing1.to_ld_json).to eq "<script type=\"application/ld+json\">\n{" +
                                          "\"@context\":\"http://schema.org\"," +
                                          "\"@type\":\"Thing\"," +
                                          "\"@id\":\"https:/thing1/\"," +
                                          "\"description\":\"description1\"," +
                                          "\"url\":\"https:/thing1/\"" +
                                          "}\n</script>"
    end

    it 'everything is nil' do
      thing1.name        = nil
      thing1.description = nil
      thing1.url         = nil
      expect(thing1.to_ld_json).to eq "<script type=\"application/ld+json\">\n{" +
                                          "\"@context\":\"http://schema.org\"," +
                                          "\"@type\":\"Thing\"" +
                                          "}\n</script>"
    end

  end

end
