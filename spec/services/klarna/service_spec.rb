require 'rails_helper'
require 'shared_examples/klarna_order_management'

describe Klarna::Service do
  # If you need to recreate the VCR cassettes for service calls, start ngrok
  # and update the URLs below with the new ngrok URL.
  let(:urls) do
    { checkout: "https://b8c2-24-91-59-172.ngrok.io/anvandare/1/betalning/#{Payment.membership_payment_type}",
      confirmation: "https://b8c2-24-91-59-172.ngrok.io/anvandare/1/betalning/'{checkout.order.id}'",
      push: "https://b8c2-24-91-59-172.ngrok.io/anvandare/betalning/klarna_push?id=1&klarna_id='{checkout.order.id}'"
    }
  end

  let(:valid_payment_data) do
    { id: '1',
      user_id: '1',
      type: Payment.membership_payment_type,
      currency: Payment.payment_currency,
      item_price: SHF_MEMBER_FEE,
      paid_item: I18n.t('payment.payment_type.member_fee'),
      urls:  urls }
  end

  let(:invalid_payment_type) { { type: 'invalid' } }

  let(:valid_order) do
    Klarna::Service.create_order(valid_payment_data)
  end

  let(:invalid_password) do
    expect(Klarna::Service).to receive(:auth)
            .and_return({ username: KLARNA_API_AUTH_USERNAME, password: 'invalid' })
  end

  ########################### Klarna "Checkout" API ###########################

  describe '.create_order', vcr: { record: :once } do

    it 'returns parsed response if successful' do
      expect(valid_order).to be_instance_of(Hash)
      expect(valid_order['merchant_reference1']).to eq '1' # user ID
      expect(valid_order['merchant_reference2']).to eq '1' # SHF Payment ID
      expect(valid_order['status']).to eq 'checkout_incomplete'
      expect(valid_order['order_amount']).to eq SHF_MEMBER_FEE
    end

    it 'raises exception if invalid payment_type' do
      expect { Klarna::Service.create_order(invalid_payment_type) }
                .to raise_exception(RuntimeError, 'Invalid payment type')
    end

    it 'raises exception if authorization fails' do
      invalid_password
      expect { valid_order }.to raise_exception(Klarna::Errors::CreateOrder,
                                                'HTTP Status: 401, Unauthorized')
    end
  end

  describe '.get_checkout_order', vcr: { record: :once } do

    it 'returns parsed response if successful' do
      klarna_order = Klarna::Service.get_checkout_order(valid_order['order_id'])

      expect(klarna_order['order_id']).to eq valid_order['order_id']
      expect(klarna_order['status']).to eq 'checkout_incomplete'
      expect(klarna_order['customer']['type']).to eq 'person'
      expect(klarna_order['order_amount']).to eq SHF_MEMBER_FEE
    end

    it 'raises exception if invalid order ID' do
      expect { Klarna::Service.get_checkout_order('not_a_valid_ID') }
                .to raise_exception(Klarna::Errors::CheckoutOrder, 'HTTP Status: 404, Not Found')
    end

    it 'raises exception if authorization fails' do
      valid_order
      invalid_password
      expect { Klarna::Service.get_checkout_order(valid_order['order_id']) }
                .to raise_exception(Klarna::Errors::CheckoutOrder, 'HTTP Status: 401, Unauthorized')
    end
  end


  ####################### Klarna "Order Management" API #######################

  # The Order Management API will only return the order *after* the user has
  # successfully completed the purchase, aka checkout process.
  # For this reason, tests below do not include invoking the Klarna API.

  describe '.get_order', vcr: { record: :once } do
    include_examples 'Invalid Request Data', :get_order,
                                             Klarna::Errors::GetOrder
  end

  describe '.acknowledge_order', vcr: { record: :once } do
    include_examples 'Invalid Request Data', :acknowledge_order,
                                             Klarna::Errors::AcknowledgeOrder
  end

  describe '.capture_order', vcr: { record: :once } do
    include_examples 'Invalid Request Data', :capture_order,
                                             Klarna::Errors::CaptureOrder,
                                             SHF_MEMBER_FEE
  end
end
