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


  it '_to_json_struct' do
    expect(thing1._to_json_struct).to eq({ 'description' => 'description1',
                                           'name'        => 'thing1',
                                           'url'         => 'https:/thing1/' })
  end


  # This test isn't necessary.  But it's good to know it all works.
  it 'to_ld_json' do

    expect(thing1.to_ld_json).to eq "<script type=\"application/ld+json\">\n{" +
                                        "\"@context\":\"http://schema.org\"," +
                                        "\"@type\":\"Thing\"," +
                                        "\"@id\":\"https:/thing1/\"," +
                                        "\"name\":\"thing1\"," +
                                        "\"description\":\"description1\"," +
                                        "\"url\":\"https:/thing1/\"" +
                                        "}\n</script>"
  end

end
