require 'rails_helper'

RSpec.describe PaymentsController, type: :controller do

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:company) { create(:company) }
  let(:payment) { create(:payment, user: user1, company: company) }
  let(:application) { create(:shf_application, user: user1, companies: [company]) }

  let(:webhook_payload) do
    resource = { 'id' => 'hips_id', 'status' => 'successful',
                 'merchant_reference' => { 'order_id' => payment.id } }
    { 'event' => 'order.successful', 'jwt' => resource }
  end

  describe 'routing' do
    it 'routes POST /anvandare/:user_id/betalning/:type to payment#create' do
      expect(post: '/anvandare/1/betalning/member_fee')
        .to route_to(controller: 'payments', action: 'create',
                     user_id: '1', type: Payment::PAYMENT_TYPE_MEMBER)

      expect(post: '/anvandare/1/betalning/branding_fee?company_id=1')
        .to route_to(controller: 'payments', action: 'create',
                     user_id: '1', company_id: '1',
                     type: Payment::PAYMENT_TYPE_BRANDING)
    end
  end

  describe 'POST #create' do
    let(:request) do
      post :create, params: { user_id: user1.id, type: Payment::PAYMENT_TYPE_MEMBER }
    end

    it 'handles exception if payment cannot be saved' do
      sign_in user1

      allow(HipsService).to receive(:create_order).and_return({}) # force exception

      # Cannot test 'rescue' action directly so need to confirm side effects
      expect{ request }.to_not change(Payment, :count)

      flash_msg = I18n.t('payments.create.something_wrong',
                         admin_email: ENV['SHF_REPLY_TO_EMAIL'])

      expect(flash[:alert]).to eq [flash_msg]
    end

    it 'rejects unauthorized access' do
      sign_in user2
      request

      expect(response).to have_http_status(302)
      expect(response.redirect_url).to eq root_url
      expect(flash[:alert]).to eq "#{I18n.t('errors.not_permitted')}"
    end

  end

  describe 'POST #webhook' do

    before(:each) do
      allow(JSON).to receive(:parse).and_return(webhook_payload)
      allow(HipsService).to receive(:validate_webhook_origin)
        .and_return(webhook_payload['jwt'])
    end

    it 'sets payment status to paid' do
      expect(payment.status).to eq 'skapad'
      post :webhook
      expect(payment.reload.status).to eq 'betald'
    end
  end


  describe '#success' do

    let(:payment_made) { instance_double(Payment, save: true) }

    it 'calls payment.successfully_completed on success', :vcr do

      allow(Payment).to receive(:find).and_return(payment_made)
      allow(payment_made).to receive(:payment_type).and_return( Payment::PAYMENT_TYPE_MEMBER )

      sign_in user1
      expect(payment_made).to receive(:successfully_completed)

      get :success, params: {user_id: user1.id, id: payment.id }

    end
  end
end
