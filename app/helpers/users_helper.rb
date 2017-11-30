module UsersHelper

  def most_recent_login_time user
    user.current_sign_in_at.blank? ? user.last_sign_in_at : user.current_sign_in_at
  end

  def expire_date_label_and_value user
    expire_date = user.membership_expire_date

    if !expire_date
      return field_or_none("#{t('activerecord.attributes.payment.expire_date')}",
                           "#{t('none')}", label_class: 'standard-label')
    end

    # Show expire date as yellow if within 1 month from today, red if expired
    value_class = expire_date_css_class(expire_date)

    return field_or_none("#{t('activerecord.attributes.payment.expire_date')}",
                         "#{expire_date}",
                         label_class: 'standard-label',
                         value_class: value_class)
  end

  # Return a simple string to use as a CSS class to apply an informative style
  # to the expiration date.
  #
  # There are 3 states we care about:
  #  1) we're not going to pass the expiration date soon  = 'Yes' (we're ok)
  #  2) we're going to pass the expiration date soon      = 'Maybe' (maybe we should be concerned)
  #  3) we have passed the expiration date                = 'No' (we're not ok)
  #
  # Note: Use Date.current because it returns the date/time according to this Rails application.
  #   Date.today (and Time.now) return the date/time of the _system_ time
  #  (the time according to the operating system on the machine running Rails), which may or may not be
  #   the same as the Rails application time.
  #   Likewise, use Date.new().in_time_zone instead of just Date.new
  #   @see The Exhaustive Guide to Rails Time Zones http://danilenko.org/2012/7/6/rails_timezones/
  #   @see It's About Time (Zones) https://robots.thoughtbot.com/its-about-time-zones
  #
  def expire_date_css_class(expire_date)

    today = Date.current

    if today < expire_date << 1
      value_class = 'Yes'  # green
    elsif today >= expire_date
      value_class = 'No'
    else
      value_class = 'Maybe'
    end
    value_class
  end

  def pay_member_fee_link(user)
    # Returns link styled as a button
    return nil unless user.allow_pay_member_fee?

    link_to("#{t('menus.nav.members.pay_membership')}",
            payments_path(user_id: user.id,
                          type: Payment::PAYMENT_TYPE_MEMBER),
            { method: :post, class: 'btn btn-primary btn-xs' })
  end

  def payment_notes_label_and_value(user)
    notes = user.payment_notes
    if !notes || notes.empty?
      return field_or_none("#{t('activerecord.attributes.payment.notes')}",
                           "#{t('none')}", label_class: 'standard-label')
    end
    return field_or_none("#{t('activerecord.attributes.payment.notes')}",
                         notes, label_class: 'standard-label')
  end

end
