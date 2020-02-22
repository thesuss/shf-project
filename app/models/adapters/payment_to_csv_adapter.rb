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


    def set_target_attributes(target)
      co_name = ''
      co_num = ''
      amount = 0

      payment = @adaptee

      target << payment.id
      target << quote(payment.user.full_name)
      target << payment.user.email
      target << payment.user.membership_number

      target << payment.payment_type

      if payment.payment_type == Payment::PAYMENT_TYPE_BRANDING
        co_name = payment.company.name
        co_num = payment.company.company_number
        amount = SHF_BRANDING_FEE / 100
      else
        amount = SHF_MEMBER_FEE / 100
      end

      target << amount

      target << quote(payment.start_date)
      target << quote(payment.expire_date)

      target << quote(payment.created_at.strftime('%F'))

      target << quote(co_name)
      target << co_num

      target << payment.status
      target << payment.hips_id

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
       'HIPS id',
       I18n.t('notes', scope: I18N_PAYMENT_ATTRIBS)
      ]
    end

  end

end
