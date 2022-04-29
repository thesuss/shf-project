require 'active_support/logger'
require_relative File.join('..', '..', 'update_by_task_note_formatter')

namespace :shf do
  namespace :one_time do

    include UpdateByTaskNoteFormatter

    BRANDING_FEE_ORIGINAL_AMOUNT = 25000
    BRANDING_FEE_NEW_AMOUNT_START_DATE = Time.utc(2022, 1, 20, 18)
    BRANDING_FEE_NEW_AMOUNT = 50000

    MEMBER_FEE_AMOUNT = 30000
    MEMBER_FEE_KLARNA_START_DATE = Time.utc(2021, 10, 20, 16) # 2021-10-20 16:34:33.152164 is the first Klarna payment

    def hips_payments_without_payment_processor
      Payment.where('created_at < ?', MEMBER_FEE_KLARNA_START_DATE).where(payment_processor: nil)
    end


    def successful_membership_payments_without_amounts
      Payment.send(Payment.membership_payment_type).completed.where(amount: nil)
    end


    def successful_branding_payments_without_amounts_original_amount
      Payment.send(Payment.branding_license_payment_type).completed.where(amount: nil).where('created_at < ?', BRANDING_FEE_NEW_AMOUNT_START_DATE)
    end


    def successful_branding_payments_without_amounts_new_amount
      Payment.send(Payment.branding_license_payment_type).completed.where(amount: nil).where('created_at >= ?', BRANDING_FEE_NEW_AMOUNT_START_DATE)
    end


    # Update the attribute for the payment, append the note to the payment notes
    def update_payment(payment, attribute, new_value, new_note)
      # Can't use update because that will call validate, which may fail if the klarna_id is nil,
      # which can happen if the payment was a payment done by HIPS (as the payment processor)
      payment.update_columns(attribute => new_value,
                             notes: [payment.notes, new_note].compact.join(' | '),
                             updated_at: Time.now.utc)
    end


    def update_amounts(payments = [], new_amount, task_name, log)
      num_changed = 0
      payments.each do |payment|
        attribs_change_note = entity_attrib_change_note('Payment', payment.id, :amount, payment.amount, new_amount)
        update_message = create_update_note(task_name, 'Payment', payment.id, :amount, payment.amount, new_amount)
        update_result_ok = update_payment(payment, :amount, new_amount, update_message)
        raise "#{payment.errors.full_messages.join(';')}" unless update_result_ok
        log.info(attribs_change_note)
        num_changed += 1
      rescue => error
        log.error(">> ERROR! Could not update payment amount: Payment id = #{payment.id}.  Error = #{error.message}")
        next
      end
      num_changed
    end


    desc 'populate past payment amounts and processors'
    task populate_past_payment_amounts_and_processors: [:environment] do |this_task|
      task_name_end = this_task.to_s.split(':').last # the task name without the namespace(s)
      log_msg_starter = 'Populate past payment amounts and processors.'

      ActivityLogger.open(LogfileNamer.name_for("SHF-one-time-task-#{task_name_end}"), 'OneTimeRakeTask', task_name_end) do |log|
        log.info(log_msg_starter)
        begin

          # Hips payment processor
          # populate with HIPS as the payment processor if the payment was created before Klarna started
          num_payments_processor_changed = 0
          hips_processor = Payment.payment_processor_hips
          hips_with_no_processor = hips_payments_without_payment_processor
          hips_with_no_processor.each do |payment|
            begin
              attribs_change_note = entity_attrib_change_note('Payment', payment.id, :payment_processor, payment.payment_processor, hips_processor)
              update_message = create_update_note("#{this_task}", 'Payment', payment.id, :payment_processor, payment.payment_processor, hips_processor)
              update_result_ok = update_payment(payment, :payment_processor, hips_processor, update_message)
              raise "#{payment.errors.full_messages.join(';')}" unless update_result_ok
              log.info(attribs_change_note)
              num_payments_processor_changed += 1
            rescue => error
              log.error(">> ERROR! Could not update payment processor: Payment id = #{payment.id}.  Error = #{error.message}")
              next
            end
          end

          # Member fees: only populate successful payments without amounts
          member_fee_no_amounts = successful_membership_payments_without_amounts
          num_membership_payments_amounts_changed = update_amounts(member_fee_no_amounts, MEMBER_FEE_AMOUNT, this_task.to_s, log)

          # Branding fees: only populate successful payments without amounts
          branding_fee_no_amounts_orig_price = successful_branding_payments_without_amounts_original_amount
          num_branding_fee_payments_orig_amounts_changed = update_amounts(branding_fee_no_amounts_orig_price, BRANDING_FEE_ORIGINAL_AMOUNT, this_task.to_s, log)

          branding_fee_no_amounts_new_price = successful_branding_payments_without_amounts_new_amount
          num_branding_fee_payments_new_amounts_changed = update_amounts(branding_fee_no_amounts_new_price, BRANDING_FEE_NEW_AMOUNT, this_task.to_s, log)

          log.info(' .... done.')
          log.info("  payment processors changed:                          #{num_payments_processor_changed}")
          log.info("  membership fee amounts changed to #{MEMBER_FEE_AMOUNT}:             #{num_membership_payments_amounts_changed}")
          log.info("  branding fees changed to the original amount #{BRANDING_FEE_ORIGINAL_AMOUNT}:  #{num_branding_fee_payments_orig_amounts_changed}")
          log.info("  branding fees changed to the new amount #{BRANDING_FEE_NEW_AMOUNT}:       #{num_branding_fee_payments_new_amounts_changed}")
        end
      end
    end

  end
end
