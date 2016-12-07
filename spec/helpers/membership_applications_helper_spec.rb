require 'rails_helper'

RSpec.describe MembershipApplicationsHelper, type: :helper do

  describe '#member_full_name' do
    it 'appends first and last with a space inbetween' do
      assign(:membership_application, create(:membership_application, first_name: 'Kitty', last_name: 'Kat', user: create(:user)))
      expect(helper.member_full_name).to eq('Kitty Kat')
    end

  end

end
