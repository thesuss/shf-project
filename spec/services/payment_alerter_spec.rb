require 'rails_helper'

RSpec.describe PaymentAlerter do
  let(:subject) { described_class.instance }

  let(:mock_email_msg) { instance_double('Mail::Message') }
  let!(:test_user) { create(:member, email: 'user@example.com') }
  let(:branding_fee_payment) { build(:h_branding_fee_payment, user: test_user) }
  let(:membership_payment) { build(:membership_fee_payment, user: test_user) }


  describe 'payment_made' do

    it 'delivers payment_made message to the user when membership fee is paid' do
      expect(PaymentMailer).to receive(:payment_made).with(membership_payment).and_return(mock_email_msg)
      expect(mock_email_msg).to receive(:deliver)
      subject.payment_made(membership_payment)
    end 

    it 'delivers payment_made message to the user when branding fee is paid' do
      expect(PaymentMailer).to receive(:payment_made).with(branding_fee_payment).and_return(mock_email_msg)
      expect(mock_email_msg).to receive(:deliver)
      subject.payment_made(branding_fee_payment)
    end 
    
  end

end