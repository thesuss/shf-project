require 'rails_helper'

require 'shared_context/users'


RSpec.describe AdminOnly::GetMembersNeedingPackets do

  # @todo Can any of the queries or objects be mocked?
  describe '.members with no welcome packet sent' do

    include_context 'create users'

    # Payment start date just needs to be a few days before today so it's clear
    #   that the membership term has started but hasn't ended yet
    let(:payment_start_date) { Date.today - 10 }

    def create_member_with_payments(payment_start, first_name = '')
      create(:member, first_day: payment_start, first_name: first_name)
    end

    let(:applicant) do
      appl = applicant_approved_no_payments # from shared context
      appl.update(first_name: 'Applicant') # email_1
      appl
    end

    let(:member_no_pkt_1) { create(:member, first_day: payment_start_date, first_name:  'No Pkt 1') }
    let(:member_no_pkt_2) { create(:member, first_day: payment_start_date + 1, first_name:  'No Pkt 2')}
    let(:member_expired) {  create(:member, first_day: payment_start_date - 400, first_name: 'Expired') }
    let(:member_pkt_sent) do
      mem_pkt_sent =  create(:member, first_day: payment_start_date, first_name:  'Pkt Sent')
      mem_pkt_sent.update(date_membership_packet_sent: payment_start_date)
      mem_pkt_sent
    end

    let(:co1) { member_no_pkt_1.shf_application.companies.first }
    let(:co2) { member_no_pkt_2.shf_application.companies.first }
    let(:co3_pkt_sent) { member_pkt_sent.shf_application.companies.first }

    let(:companies_with_members) { [co1, co2, co3_pkt_sent] }

    before(:each) do
      allow(co1).to receive(:current_members).and_return([member_no_pkt_1])
      allow(co2).to receive(:current_members).and_return([member_no_pkt_2])
      allow(co3_pkt_sent).to receive(:current_members).and_return([member_pkt_sent])

      allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true)
    end

    it 'calls Company.current_with_current_members to get the list of current members in current (licensed) Companies' do
      expect(Company).to receive(:current_with_current_members).and_return([])
      described_class.members_with_no_membership_packet
    end

    it 'has no duplicates' do
      allow(Company).to receive(:current_with_current_members)
                          .and_return(companies_with_members)
      result = described_class.members_with_no_membership_packet

      expected_member_no_pkt_1 = User.find_by(first_name: 'No Pkt 1')
      expectedmember_no_pkt_2 = User.find_by(first_name: 'No Pkt 2')
      expect(result.to_a).to match_array([expected_member_no_pkt_1,
                                          expectedmember_no_pkt_2])
    end


    it 'no member has a membership packet sent' do
      allow(Company).to receive(:current_with_current_members)
                          .and_return(companies_with_members)
      result = described_class.members_with_no_membership_packet

      expect(result.to_a.select(&:membership_packet_sent?)).to be_empty
    end

    it 'is sorted by the membership payment term start date' do
      allow(Company).to receive(:current_with_current_members)
                          .and_return(companies_with_members)
      result = described_class.members_with_no_membership_packet

      expect(result.first).to eq(User.find_by(first_name: 'No Pkt 1'))
      expect(result.last).to eq(User.find_by(first_name: 'No Pkt 2'))
    end
  end
end
