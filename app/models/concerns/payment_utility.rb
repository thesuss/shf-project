module PaymentUtility
  extend ActiveSupport::Concern

  included do

    def most_recent_payment(payment_type)
      payments.completed.send(payment_type).order(:created_at).last
    end

    def payment_start_date(payment_type)
      most_recent_payment(payment_type)&.start_date
    end

    def payment_expire_date(payment_type)
      most_recent_payment(payment_type)&.expire_date
    end

    def payment_notes(payment_type)
      most_recent_payment(payment_type)&.notes
    end
  end


  # FIXME Company h-branding fee: how to determine the next payment date when no payment has been made yet?
  #   = the payment date of the first membership fee of all current members
  #   - FIXME how to store this date if/when the member is no longer a current member?
  #
  class_methods do

    # TODO should just pass in the entity.  the "id" is an implementation detail that callers should not care about.
    # TODO should just request the payment type as part of the method name.  Passing in the implementation of the payment type (e.g. Payment::PAYMENT_TYPE_BRANDING is an implementation detail that callers shouldn't care about)
    #
    # @param entity_id [Integer] - the id of the entity to get the next payment dates for
    # @param payment_type [Payment::PAYMENT_TYPE_MEMBER | Payment::PAYMENT_TYPE_BRANDING] - the specific type of the payment to look for
    #
    # @return [Array] - the start_date _and_ expire_date for the next payment
    def next_payment_dates(entity_id, payment_type)
      entity = find(entity_id)

      expire_date = entity.payment_expire_date(payment_type)

      if expire_date && expire_date.future?
        start_date = expire_date + 1.day
      else
        start_date = Time.zone.today  # can't use this to determine how many days OVERDUE the membership payment is!
      end

      expire_date = expire_date_for_start_date(start_date)

      [start_date, expire_date]
    end


    # THIS IS THE KEY RULE ABOUT WHEN PAYMENTS EXPIRE:
    def expire_date_for_start_date(start_date)
      start_date + 1.year - 1.day
    end

  end
end
