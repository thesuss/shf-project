#!/usr/bin/ruby

module Adapters

  #--------------------------
  #
  # @class PaymentToCsvAdapter
  #
  # @desc Responsibility: Takes a Payment and creates (adapts it to) CSV
  #
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   2020-02-20
  #
  #
  #--------------------------
  class PaymentToCsvAdapter < AbstractCsvAdapter

    I18N_PAYMENT_ATTRIBS = 'activerecord.attributes.payment'.freeze

    UNKNOWN = I18n.t('unknown')


    def set_target_attributes(target)
      payment = @adaptee

      target << payment.id

      target.append_items user_info(payment)

      target.append_items payment_type_info(payment)

      target.append_items payment_amount(payment)

      target.append_items term_dates(payment)

      target << quote(payment.created_at.strftime('%F'))

      target.append_items company_info(payment)

      target.append_items payment_processor_info(payment)

      target << quote(payment.notes)

      target
    end


    def self.headers(*args)

      ["#{I18n.t('activerecord.models.payment.one')} db id",
       I18n.t('name'),
       'E-post',
       I18n.t('activerecord.attributes.user.membership_number'),
       I18n.t('payment_type', scope: I18N_PAYMENT_ATTRIBS),
       'SEK',

       'Term ' + I18n.t('start_date', scope: I18N_PAYMENT_ATTRIBS),
       'Term ' + I18n.t('expire_date', scope: I18N_PAYMENT_ATTRIBS),

       'Pay. date',
       'Org.',
       I18n.t('org_nr'),
       I18n.t('status', scope: I18N_PAYMENT_ATTRIBS),
       'Payment id',
       I18n.t('notes', scope: I18N_PAYMENT_ATTRIBS)
      ]
    end


    # entries for the Payment user
    def user_info(payment)
      column_entries = []

      # There are Payments in the production db where the user_id is nil
      if payment.user
        column_entries << quote(payment.user.full_name)
        column_entries << payment.user.email
        column_entries << payment.user.membership_number

      else
        column_entries << UNKNOWN # << quote(payment.user.full_name)
        column_entries << UNKNOWN # << payment.user.email
        column_entries << UNKNOWN # << payment.user.membership_number
      end

      column_entries
    end


    def payment_type_info(payment)
      [payment.payment_type]
    end


    def company_info(payment)
      co_name = ''
      co_num = ''

      if payment.payment_type == Payment::PAYMENT_TYPE_BRANDING
        if payment.company
          co_name = payment.company.name
          co_num = payment.company.company_number
        else
          co_name = UNKNOWN
          co_num = UNKNOWN
        end
      end

      [quote(co_name), co_num]
    end


    def payment_amount(payment)
      amount = UNKNOWN
      if payment.payment_type == Payment::PAYMENT_TYPE_BRANDING
        amount = SHF_BRANDING_FEE / 100
      else
        amount = SHF_MEMBER_FEE / 100
      end

      [amount]
    end


    def term_dates(payment)
      [quote(payment.start_date), quote(payment.expire_date)]
    end


    def payment_processor_info(payment)
      payment.klarna_id.present? ? [payment.status, payment.klarna_id] :
      [payment.status, payment.hips_id]
    end
  end

end
