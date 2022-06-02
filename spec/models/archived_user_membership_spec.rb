require 'rails_helper'

RSpec.describe ArchivedUserMembership, type: :model do
  let(:given_membership) { create(:membership) } # have to use create so that the owner is also created

  describe '.create_from' do

    context "an #{described_class} for the given membership does not exist" do
      it 'a new ArchivedUserMembership is created' do
        expect( described_class.create_from(given_membership)).to be_a described_class
      end
    end

    context "an #{described_class} for the given membership already exists" do
      it 'a  AlreadyExistsError is raised' do
        described_class.create_from(given_membership)
        expect { described_class.create_from(given_membership) }.to raise_error(AlreadyExistsError)
      end
    end
  end

  describe '.attribs_from' do

    it 'gets the membership attribs and values and merges them into the attributes returned' do
      expect(described_class).to receive(:membership_attribs).and_return([:blorf, :flurb])
      expect(described_class.attribs_from(given_membership)).to include(flurb: nil, blorf: nil)
    end

    it 'gets the membership owner id and type and merges that into the attributes returned' do
      expect(described_class.attribs_from(given_membership)).to include(:owner_id, :owner_type)
    end

    it 'calls assign_specific_attribs and merges that into the attributes returned' do
      expect(described_class).to receive(:assign_specific_attribs).and_return({ flurb: 5, blorf: 'this' })
      expect(described_class.attribs_from(given_membership)).to include(flurb: 5, blorf: 'this')
    end

    it 'gets the original membership owner attributes and prefixes them with the belonged to prefix' do
      expect(described_class).to receive(:orig_attribs_for_belonged_to).and_return( [:email])
      expect(described_class.attribs_from(given_membership)).to include(belonged_to_email: given_membership.owner.email)
    end
  end
end
