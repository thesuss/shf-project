require_relative('../seed_helpers.rb')
require_relative '../require_all_seeders_and_helpers'

module SeedHelpers
  #--------------------------
  #
  # @class PaymentsFactory
  #
  # @desc Responsibility: Create Payments with specific attributes, etc.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2022/04/09
  #
  #--------------------------
  #
  class PaymentsFactory

    # --------------------------------------------------------------------------------------------

    def self.faux_processor_id
      "#{(Time.now.to_f * 10000000).to_i}"
    end


    def self.default_payment_status
      Payment.status_successful
    end


    # --------------------------------------------------------------------------------------------

    def initialize(static_data = SeedHelpers::StaticDataFactory.new, log = nil)
      @static_data = static_data
      @log = log
    end


    def new_hips_pending_membership_payment(user, first_day, last_day)
      new_hips_membership_payment(user, first_day, last_day, status: Payment.status_hips_pending)
    end


    def new_hips_membership_payment(user, term_first_day, term_last_day, status: Payment.status_hips_successful)
      new_membership_payment(user, term_first_day, term_last_day,
                             status: status,
                             payment_processor: Payment.payment_processor_hips,
                             id_method: :hips_id)
    end


    def new_hips_hmarkt_payment(user, term_first_day, term_last_day, status: Payment.status_hips_successful)
      new_hmarkt_payment(user, term_first_day, term_last_day,
                         status: status,
                         payment_processor: Payment.payment_processor_hips,
                         id_method: :hips_id)
    end


    def new_klarna_pending_membership_payment(user, first_day, last_day)
      new_klarna_membership_payment(user, first_day, last_day, status: Payment.status_pending)
    end


    def new_klarna_membership_payment(user, term_first_day, term_last_day, status: self.class.default_payment_status)
      new_membership_payment(user, term_first_day, term_last_day,
                             status: status,
                             payment_processor: Payment.payment_processor_klarna,
                             id_method: :klarna_id)
    end


    def new_klarna_pending_hmarkt_payment(user, first_day, last_day)
      new_klarna_hmarkt_payment(user, first_day, last_day, status: Payment.status_pending)
    end


    def new_klarna_hmarkt_payment(user, term_first_day, term_last_day, status: self.class.default_payment_status)
      new_hmarkt_payment(user, term_first_day, term_last_day,
                         status: status,
                         payment_processor: Payment.payment_processor_klarna,
                         id_method: :klarna_id)
    end


    def new_membership_payment(user, term_first_day, term_last_day,
                               status: Payment.status_successful,
                               payment_processor: Payment.payment_processor_klarna,
                               processor_id: self.class.faux_processor_id,
                               id_method: :klarna_id)
      Payment.create(payment_type: Payment.membership_payment_type,
                     user_id: user.id,
                     id_method => processor_id,
                     payment_processor: payment_processor,
                     status: status,
                     start_date: term_first_day,
                     expire_date: term_last_day)
    end


    def new_hmarkt_payment(user, term_first_day, term_last_day,
                           status: self.class.default_payment_status,
                           payment_processor: Payment.payment_processor_klarna,
                           processor_id: self.class.faux_processor_id,
                           id_method: :klarna_id)
      Payment.create(payment_type: Payment.branding_license_payment_type,
                     user_id: user.id,
                     company_id: user.companies.first.id,
                     id_method => processor_id,
                     payment_processor: payment_processor,
                     status: status,
                     start_date: term_first_day,
                     expire_date: term_last_day)
    end

  end

end
