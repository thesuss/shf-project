# frozen_string_literal: true

#--------------------------
#
# @class PaymentCoveringYear
#
# @desc Responsibility: Simple class that calculates how many days of a year a payment covered.
#  It has a payment and a year, and can do the simple calculations.
#
# TODO this should be a Singleton
#
# @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
# @date   2/20/20
#
#--------------------------

class PaymentCoveringYear

  attr_accessor :year, :payment

  ROUND_PREC = 2


  # @fixme This is currently defined in config/initializers/hips_service.rb TODO: Should be AppConfiguration value
  def self.membership_fee_amount
    SHF_MEMBER_FEE
  end

  # @fixme This is currently defined in config/initializers/hips_service.rb TODO: Should be AppConfiguration value
  def self.branding_license_fee_amount
    SHF_BRANDING_FEE
  end


  def initialize(payment: Payment.create, year: Time.zone.today.year)
    @payment = payment
    @year = year
  end


  # the amount is in 100s of SEK (so divide by 100)
  def payment_amount
    (payment.payment_type == Payment::PAYMENT_TYPE_MEMBER ? self.class.membership_fee_amount : self.class.branding_license_fee_amount) / 100
  end


  def days_paid_for_year
    (sek_per_day * num_days_of_year_covered).round(ROUND_PREC)
  end


  def sek_per_day
    payment_amount.fdiv(total_number_of_days_paid).round(ROUND_PREC)
  end


  def percent_of_year_covered
    return 100 if payment_covers_more_than_year?
    (num_days_of_year_covered.fdiv(days_in_year) * 100).round(ROUND_PREC)
  end


  def total_number_of_days_paid
    (payment.expire_date - payment.start_date + 1).to_i
  end


  def num_days_of_year_covered
    return days_in_year if payment_covers_more_than_year?

    starting_date = (payment.start_date < year_start) ? year_start : payment.start_date
    ending_date = (payment.expire_date > year_end) ? year_end : payment.expire_date

    (ending_date - starting_date + 1).to_i # Add 1 because the ending date should count as a full day
  end


  def payment_covers_more_than_year?
    payment.start_date < year_start && payment.expire_date > year_end
  end


  def days_in_year
    ((year_start + 1.year) - year_start).to_i
  end


  def year_start
    DateTime.new(year, 1, 1)
  end


  def year_end
    year_start.end_of_year
  end

end
