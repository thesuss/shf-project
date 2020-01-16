require 'shared_context/named_dates'

# This creates these users: (all use create() unless "[uses build()]" is noted in the description below)
#   (Note that 'shared_context/named_dates' defines THIS_YEAR; last year = THIS_YEAR - 1; next year = THIS_YEAR + 1)
#
# user - a user (no payments, not a member)
# user_no_payments - a user (no payments, not a member)
# user_all_paid_membership_not_granted-[uses create(), then saves] a user not yet granted membership with an approved membership application, membership and company payments made today
# member_paid_up - [uses build(), then saves] a member with a membership application and a membership payment made today
# member_expired - [uses build(), then saves] a member with a membership application and a membership payment that expired yesterday
# user_pays_every_nov30 - current member with membership app; paid membership fee Nov 30 last year; paid branding fee Nov 30 last year; paid membership fee Nov 30 THIS_YEAR; paid branding fee Nov 30 THIS_YEAR;
# user_paid_only_lastyear_dec_2 - member with membership app; paid membership fee Dec 2 last year; paid branding fee Dec 2 last year
# user_paid_lastyear_nov_29 - member with membership app; paid membership fee Nov 29 last year; paid branding fee Nov 29 last year
# user_unsuccessful_this_year - member with membership app; unsuccessful membership fee Nov 29 THIS_YER; unsuccessful branding fee Nov 29 THIS_YEAR; successful membership fee Nov 30 last year; successful branding fee Nov 30 last year
# user_membership_expires_EOD_jan29 - member with membership app; membership term and branding fee term expire end of day (EOD) Jan 29 next year
# user_membership_expires_EOD_jan30 - member with membership app; membership term and branding fee term expire end of day (EOD) Jan 30 next year
# user_membership_expires_EOD_jan31 - member with membership app; membership term and branding fee term expire end of day (EOD) Jan 31 next year
# user_membership_expires_EOD_feb1 - member with membership app; membership term and branding fee term expire end of day (EOD) Feb 1 next year
# user_membership_expires_EOD_feb2 - member with membership app; membership term and branding fee term expire end of day (EOD) Feb 2 next year
# user_membership_expires_EOD_dec7 - member with membership app; membership term and branding fee term expire end of day (EOD) Dec 7 next year
# user_membership_expires_EOD_dec8 - member with membership app; membership term and branding fee term expire end of day (EOD) Dec 8 next year
# user_membership_expires_EOD_dec9 - member with membership app; membership term and branding fee term expire end of day (EOD) Dec 8 next year
#
RSpec.shared_context 'create users' do

  include_context 'named dates'

  let(:user) { create(:user) }

  let(:user_no_payments) { create(:user) }


  let(:user_all_paid_membership_not_granted) do
    user = create(:user_with_membership_app)
    app = user.shf_application
    app.state = :accepted
    app.when_approved = Time.zone.now

    user.payments << create(:membership_fee_payment)
    user.payments << create(:h_branding_fee_payment, company: app.companies.first)
    user.save!
    user
  end


  let(:member_paid_up) do
    user = build(:member_with_membership_app)
    user.payments << create(:membership_fee_payment)
    user.save!
    user
  end

  let(:member_expired) do
    user = build(:member_with_membership_app)
    user.payments << create(:expired_membership_fee_payment)
    user.save!
    user
  end

  # member that paid successfully _last_ year but UNsuccessfully _this_ year
  let(:user_unsuccessful_this_year) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    # success on nov 30 last year
    Timecop.freeze(lastyear_nov_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_30,
             expire_date: User.expire_date_for_start_date(lastyear_nov_30),
             notes:       'lastyear_nov_30 success membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_nov_30,
             expire_date: Company.expire_date_for_start_date(lastyear_nov_30),
             notes:       'lastyear_nov_30 success branding')
    end

    # failed on nov 29
    Timecop.freeze(nov_29) do
      create(:membership_fee_payment,
             :expired,
             user:        u,
             company:     u_co,
             start_date:  nov_29,
             expire_date: User.expire_date_for_start_date(nov_29),
             notes:       'nov_29 failed (expired) membership')
      create(:h_branding_fee_payment,
             :expired,
             user:        u,
             company:     u_co,
             start_date:  nov_29,
             expire_date: Company.expire_date_for_start_date(nov_29),
             notes:       'nov_29 failed (expired) branding')
    end

    u
  end


  # Create a member with an accepted membership application with
  #  successful member fee and branding license payments made on each
  #  of the payment_start_dates.
  #
  # @param [Array] payment_start_dates - list of start dates [Date] for
  #  successful member fee and branding license payments to be created.
  #  Timecop will freeze the time to this date so the payments will be 'created' on this date.
  #
  # @return [User] - the member created
  def create_member_with_payments_on(payment_start_dates = [Date.today])
    new_member = create(:member_with_membership_app)
    new_member_co = new_member.shf_application.companies.first

    payment_start_dates.each do | payment_start_date |

      Timecop.freeze(payment_start_date) do

        membership_fee_expiry = User.expire_date_for_start_date(payment_start_date)
        create(:membership_fee_payment,
               :successful,
               user:        new_member,
               company:     new_member_co,
               start_date:  payment_start_date,
               expire_date: membership_fee_expiry,
               notes:       "membership starts #{payment_start_date.to_date}, expires #{membership_fee_expiry.to_date}")

        branding_fee_expiry = Company.expire_date_for_start_date(payment_start_date)
        create(:h_branding_fee_payment,
               :successful,
               user:        new_member,
               company:     new_member_co,
               start_date:  payment_start_date,
               expire_date: branding_fee_expiry,
               notes:       "branding license starts #{payment_start_date.to_date}, expires #{branding_fee_expiry.to_date}")
      end
    end

    new_member
  end


  let(:user_pays_every_nov30) { create_member_with_payments_on([lastyear_nov_30, nov_30]) }

  let(:user_paid_only_lastyear_dec_2) { create_member_with_payments_on([lastyear_dec_2]) }

  let(:user_paid_lastyear_nov_29) { create_member_with_payments_on([lastyear_nov_29]) }

  let(:user_membership_expires_EOD_jan29) { create_member_with_payments_on([jan_30]) }
  let(:user_membership_expires_EOD_jan30) { create_member_with_payments_on([jan_31]) }
  let(:user_membership_expires_EOD_jan31) { create_member_with_payments_on([feb_1]) }
  let(:user_membership_expires_EOD_feb1) { create_member_with_payments_on([feb_2]) }

  let(:user_membership_expires_EOD_dec7) { create_member_with_payments_on([lastyear_dec_8]) }
  let(:user_membership_expires_EOD_dec8) { create_member_with_payments_on([lastyear_dec_9]) }
  let(:user_membership_expires_EOD_dec9) { create_member_with_payments_on([lastyear_dec_10]) }
end
