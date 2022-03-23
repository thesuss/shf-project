module Klarna
  module Errors
    class KlarnaError < StandardError; end
    class CreateOrder < KlarnaError; end
    class CheckoutOrder < KlarnaError; end
    class GetOrder < KlarnaError; end
    class AcknowledgeOrder < KlarnaError; end
    class CaptureOrder < KlarnaError; end
  end
end
