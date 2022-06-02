require 'rails_helper'

RSpec.describe ArchivedCompanyMembership, type: :model do
  let(:given_membership) { create(:company_membership) }  # have to use create so that the owner is also created

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
end
