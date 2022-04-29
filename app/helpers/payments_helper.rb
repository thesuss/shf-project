module PaymentsHelper

  CURRENCY_STR_KR = 'kr'

  # Create a <span> that has the expire date for the entity with the CSS class
  # set based on whether or not the date has expired and a tooltip that explains it.
  #
  # @param entity [User | Object]- the entity that provides the expiration date. If a User,
  # must respond to :entity_expire_date
  #
  # @return [String] - the HTML <span> string
  def expire_date_label_and_value(entity,
                                  label_class: default_field_label_css_class,
                                  value_class: default_field_value_css_class)

    expire_date = entity_expire_date(entity)
    t_scope = entity_i18n_scope(entity)

    expire_after_tooltip_title = t("#{t_scope}.show.term_expire_date_tooltip")
    expire_label = t("#{t_scope}.show.term_paid_through")

    if expire_date
      tag.div do
        concat tag.span "#{expire_label}: ", class: label_class
        concat tag.span "#{expire_date}", class: [payment_due_now_hint_css_class(entity), value_class]
        concat ' '
        concat fas_tooltip(expire_after_tooltip_title)
      end
    else
      field_or_none(expire_label, t('none_t'), label_class: 'standard-label')
    end
  end


  # TODO - this is a smell (checking the class): polymorphism should be used instead. Default implementation should be in a parent class for User and Company
  def entity_name_and_number_html(entity, i18n_scope)
    num = entity_value(entity, :membership_number, :company_number)
    num_title = entity.is_a?(User) ? t('membr_nr', scope: i18n_scope) : t('org_nr', scope: i18n_scope)
    "#{entity_name(entity)} <span class='entity-number'>#{num_title.downcase} #{num}</span>"
  end

  # TODO - this is a smell (checking the class): polymorphism should be used instead. Default implementation should be in a parent class for User and Company
  def entity_name(entity)
    entity_value(entity, :full_name, :name, I18n.t('name_missing'))
  end


  # @param entity [User or Company] - the entity with a possible membership expiration date
  # @return [nil | date] - return nil if there is no expiration date (e.g. not a member), else
  # the Date that the current membership term expires
  # TODO - this is a smell (checking the class): polymorphism should be used instead. Default implementation should be in a parent class for User and Company
  def entity_expire_date(entity = nil)
    entity_value(entity, :membership_expire_date, :branding_expire_date, nil)
  end


  # @return [String] - the scope (= key) to use when looking up I18n translations
  # for this entity.  Default = 'users'
  # TODO - this is a smell (checking the class): polymorphism should be used instead. Default implementation should be in a parent class for User and Company
  def entity_i18n_scope(entity = nil)
    (entity && entity.is_a?(Company)) ? 'companies' : 'users'
  end


  # @return [String] - The I18n.t string that says if a payment is due now, is past due, or isn't due now.
  def payment_due_hint(entity)
    t("payors.#{entity.payment_due_status}", due_date: entity.payment_expire_date)
  end


  # Another possible name for this method: payment_status_ok_indicator_css_class
  # The word "indicator" is good. It's possibly better than "hint"
  #
  # This method name ends with '_css_class' to make it clear that this returns
  # a CSS class as opposed to a normal Ruby class.
  #
  # @return [String] - the CSS class that should be applied based on whether or
  # not a payment is due, and how soon the payment is due
  #
  def payment_due_now_hint_css_class(entity)
    case entity.payment_due_status
      when :too_early then yes_css_class
      when :due, :past_due then no_css_class
      else maybe_css_class
    end
  end


  def expires_soon_hint_css_class(expire_date)
    today = Time.zone.today
    if today < expire_date.months_ago(1) # expire_date minus one month
      value_class = yes_css_class
    elsif today >= expire_date
      value_class = no_css_class
    else
      value_class = maybe_css_class
    end
    value_class
  end


  # TODO standardize this method name:  should it end in '_css_classes' to make it clear it is not related to Ruby classes?
  def payment_button_classes(additional_classes = [])
    %w(btn btn-secondary btn-sm) + additional_classes
  end


  def payment_button_tooltip_text(t_scope: 'users', payment_due_now: true)
    translation_scope = I18n.exists?(t_scope) ? t_scope : 'users'
    pay_button_tooltip = t("#{translation_scope}.show.payment_tooltip")
    pay_button_tooltip += " #{t('payors.no_payment_due_now')}" unless payment_due_now
    pay_button_tooltip
  end


  # TODO abstract out to Payor
  # @return [String] - HTML to display a label and value for payment notes
  def payment_notes_label_and_value(notes = '')
    display_text = notes.blank? ? t('none_plur') : notes

    field_or_none("#{t('activerecord.attributes.payment.notes')}",
                  display_text, tag: :div)
  end


  def product(payment, scope)
    payment.membership_payment? ? t('membership', scope: scope).capitalize : t('h_brand', scope: scope)
  end

  def product_with_name(payment, scope)
    payment.membership_payment? ? t('membership', scope: scope) : t('h_brand_with_name', scope: scope, company: payment.company&.name)
  end

  def payment_date(payment)
    payment.created_at.in_time_zone('CET').strftime('%Y-%m-%d %H:%M:%S (%Z)')
  end

  def payment_amount(payment)
    payment.amount.nil? ? '' : payment.amount / 100.00
  end

  # @return [String] show the payment amount with ' kr' appended
  def payment_amount_kr(payment)
    return '' if payment.amount.nil?

    payment_amount_currency(payment, CURRENCY_STR_KR)
  end

  # ------------------------------------------

  def plain_payments(payments = [], i18n_scope = '')
    payments.map do |payment|
      { id: payment.id,
        date: payment_date(payment),
        amount: payment_amount(payment),
        product: product(payment, i18n_scope),
        target_entity: entity_name_and_number_html(payment.target_entity, i18n_scope),
        payment_processor: payment.payment_processor,
        processor_id: payment.processor_id
      }
    end
  end

  # @return [Hash] a Hash that has the I18n.t value for each key
  def payment_receipts_i18n_tags(i18n_scope = '')
    tags = [:payment_date, :price, :product, :for, :payment_processor, :order_number]
    i18n_tags = {}
    tags.each do |tag|
      i18n_tags[tag] = t(tag.to_s, scope: i18n_scope)
    end
    i18n_tags
  end


  # -----------------------------------------------------------------------------------------------

  private


  # Get the value from the entity from sending the method.
  # Use the user_method if it is a User, company_method if it's a Company.
  # TODO - this is a smell (checking the class): polymorphism should be used instead.
  #   Default implementation should be in a parent class for User and Company, or included as a mixin.
  #
  # @return [Object, nil] - the value returned by sending the appropriate method to the entity.
  #   return the else_value if the entity is nil or if it is neither a User nor a Company
  def entity_value(entity, user_method, company_method, else_value = nil)
    if entity && (entity.is_a?(User) || entity.is_a?(Company))
      entity.is_a?(User) ? entity.send(user_method.to_sym) : entity.send(company_method.to_sym)
    else
      else_value
    end
  end

  # @return [String] payment amount with the currency appended (space in between amount and currency)
  def payment_amount_currency(payment, currency_str = CURRENCY_STR_KR)
    "#{payment_amount(payment)} #{currency_str}"
  end
end
