# Shared specification examples for Klarna Order Management API

RSpec.shared_examples 'Invalid Request Data' do | klass_method, expected_exception, args |

  let(:invalid_password) do
    expect(Klarna::Service).to receive(:auth)
            .and_return({ username: KLARNA_API_AUTH_USERNAME, password: 'invalid' })
  end

  it 'raises exception if invalid order ID' do

    if args
      expect { described_class.send(klass_method, 'not_a_valid_ID', args) }
        .to raise_exception(expected_exception, 'HTTP Status: 400, Bad Request')
    else
      expect { described_class.send(klass_method, 'not_a_valid_ID') }
        .to raise_exception(expected_exception, 'HTTP Status: 400, Bad Request')
    end
  end

  it 'raises exception if authorization fails' do
    invalid_password

    if args
      expect { Klarna::Service.get_order(valid_order['order_id'], args) }
        .to raise_exception(Klarna::Errors::CreateOrder, 'HTTP Status: 401, Unauthorized')
    else
      expect { Klarna::Service.get_order(valid_order['order_id']) }
        .to raise_exception(Klarna::Errors::CreateOrder, 'HTTP Status: 401, Unauthorized')
    end
  end
end
