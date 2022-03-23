# Interface to Klarna Checkout service API
# https://developers.klarna.com/api/#checkout-api
module Klarna
  include Klarna::Errors

  class Service
    require 'httparty'

    SUCCESS_CODES = [200, 201, 202, 204].freeze

    KLARNA_COLOR_BUTTON = '#003a78'.freeze
    KLARNA_COLOR_BUTTON_TEXT = '#ffffff'.freeze
    KLARNA_COLOR_HEADER = '#232525'.freeze
    KLARNA_ALLOWED_CUSTOMER_TYPES = [ 'person', 'organization' ].freeze
    KLARNA_CONTENT_TYPE = "application/vnd.klarna.internal.emd-v2+json".freeze
    KLARNA_ORDER_TYPE = 'digital'.freeze

    def self.create_order(payment_data)

      raise 'Invalid payment type' unless
        payment_data[:type] == Payment.membership_payment_type ||
        payment_data[:type] == Payment.branding_license_payment_type

      response = HTTParty.post(KLARNA_CHECKOUT_URL,
                               basic_auth: auth,
                               headers: { 'Content-Type' => 'application/json' },
                               body: order_json(payment_data))

      return response.parsed_response if SUCCESS_CODES.include?(response.code)

      begin
        process_api_error(response)
      rescue Klarna::Errors::KlarnaError
        raise Klarna::Errors::CreateOrder, "HTTP Status: #{response.code}, #{response.message}"
      end
    end

    def self.get_checkout_order(klarna_id)
      # Fetch order using the Checkout API

      url = KLARNA_CHECKOUT_URL + "#{klarna_id}"

      response = HTTParty.get(url,
                              basic_auth: auth,
                              headers: { 'Content-Type' => 'application/json' })

      return response.parsed_response if SUCCESS_CODES.include?(response.code)

      begin
        process_api_error(response)
      rescue Klarna::Errors::KlarnaError
        raise Klarna::Errors::CheckoutOrder, "HTTP Status: #{response.code}, #{response.message}"
      end
    end

    def self.get_order(klarna_id)
      # Fetch order using the Order Management API

      url = KLARNA_ORDER_MGMT_URL + "#{klarna_id}"

      response = HTTParty.get(url,
                              basic_auth: auth,
                              headers: { 'Content-Type' => 'application/json' })

      return response.parsed_response if SUCCESS_CODES.include?(response.code)

      begin
        process_api_error(response)
      rescue Klarna::Errors::KlarnaError
        raise Klarna::Errors::GetOrder, "HTTP Status: #{response.code}, #{response.message}"
      end
    end

    def self.acknowledge_order(klarna_id)

      url = KLARNA_ORDER_MGMT_URL + "#{klarna_id}" + '/acknowledge'

      response = HTTParty.post(url,
                               basic_auth: auth,
                               headers: { 'Content-Type' => 'application/json' })

      return if SUCCESS_CODES.include?(response.code)

      begin
        process_api_error(response)
      rescue Klarna::Errors::KlarnaError
        raise Klarna::Errors::AcknowledgeOrder,  "HTTP Status: #{response.code}, #{response.message}"
      end
    end

    def self.capture_order(klarna_id, payment_amount)

      url = KLARNA_ORDER_MGMT_URL + "#{klarna_id}" + '/captures'

      response = HTTParty.post(url,
                               basic_auth: auth,
                               headers: { 'Content-Type' => 'application/json' },
                               body: { captured_amount: payment_amount }.to_json)

      return if SUCCESS_CODES.include?(response.code)

      begin
        process_api_error(response)
      rescue Klarna::Errors::KlarnaError
        raise Klarna::Errors::CaptureOrder, "HTTP Status: #{response.code}, #{response.message}"
      end
    end

    def self.auth
      { username: KLARNA_API_AUTH_USERNAME, password: KLARNA_API_AUTH_PASSWORD }
    end

    def self.process_api_error(response)

      if response.code.in? [401, 404]
        raise Klarna::Errors::KlarnaError, "Response code: #{response.code}"
      else
        parsed_response = response.parsed_response

        if (error = parsed_response&.fetch('error', nil))
          raise Klarna::Errors::KlarnaError, "error: #{error['type']}, #{error['message']}"
        else
          raise Klarna::Errors::KlarnaError, 'Unknown error'
        end
      end
    end

    private_class_method def self.order_json(payment_data)

      if I18n.locale == :en && (Rails.env.development? || ENV['SHF_HEROKU_STAGING'])
        locale = 'us-en'
        country = 'US'
      else
        locale = 'sv-se'
        country = 'SE'
      end

      { locale: locale,
        options: {
          color_button: KLARNA_COLOR_BUTTON,
          color_button_text: KLARNA_COLOR_BUTTON_TEXT,
          color_header: KLARNA_COLOR_HEADER,
          allowed_customer_types: KLARNA_ALLOWED_CUSTOMER_TYPES
        },
        attachment: {
          body: { customer_account_info: [ { unique_account_identifier: payment_data[:user_id] } ] }.to_json,
          content_type: KLARNA_CONTENT_TYPE
        },
        purchase_country: country,
        purchase_currency: payment_data[:currency],
        order_amount: payment_data[:item_price],
        order_tax_amount: 0,
        merchant_reference1: payment_data[:user_id],
        merchant_reference2: payment_data[:id],
        order_lines: [
          {
            type: KLARNA_ORDER_TYPE,
            name: payment_data[:paid_item],
            quantity: 1,
            unit_price: payment_data[:item_price],
            tax_rate: 0,
            total_amount: payment_data[:item_price],
            total_tax_amount: 0
          } ],
        merchant_urls: {
          terms: 'https://sverigeshundforetagare.se/aterbetalningsvillkor/',
          checkout: payment_data[:urls][:checkout],
          confirmation: payment_data[:urls][:confirmation],
          push: payment_data[:urls][:push]
        }
      }.to_json

    end
  end
end
