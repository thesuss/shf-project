require 'rails_helper'

module Alerts
  RSpec.describe MembersNeedPacketsAlert do

    let(:subject) { described_class.instance }

    describe 'gather_content_items' do
      it 'calls GetmembersNeedingPackets to get all of the members to put in the content of the alert' do
        expect(AdminOnly::GetMembersNeedingPackets).to receive(:members_with_no_membership_packet)
        subject.gather_content_items([])
      end

      it 'the arguments are ignored' do
        expect(AdminOnly::GetMembersNeedingPackets).to receive(:members_with_no_membership_packet)
                                                         .with(no_args)
        subject.gather_content_items(['blorf', 7, 3])
      end

    end

    it '.mailer_method is members_need_packets' do
      expect(subject.mailer_method).to eq :members_need_packets
    end

    it '.mailer_args for an admin returns [items_list]' do
      admin = build(:admin)
      faux_user = 'Bob Cat'
      allow(subject).to receive(:items_list).and_return([faux_user])
      allow(subject).to receive(:gather_content_items).and_return([faux_user])

      expect(subject.mailer_args(admin)).to match_array([[faux_user]])
    end
  end
end
