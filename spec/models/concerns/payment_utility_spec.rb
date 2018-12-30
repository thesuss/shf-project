require 'rails_helper'


# We use the User class to test the instance methods since it includes the PaymentUtility class

RSpec.describe User, type: :model do

  THIS_YEAR = 2018

  let(:jul_1) { Time.zone.local(THIS_YEAR, 7, 1) }
  let(:nov_29) { Time.zone.local(THIS_YEAR, 11, 29) }
  let(:nov_30) { Time.zone.local(THIS_YEAR, 11, 30) }
  let(:dec_1) { Time.zone.local(THIS_YEAR, 12, 1) }
  let(:dec_2) { Time.zone.local(THIS_YEAR, 12, 2) }
  let(:dec_3) { Time.zone.local(THIS_YEAR, 12, 3) }

  let(:nov_29_last_year) { Time.zone.local(THIS_YEAR - 1, 11, 29) }
  let(:nov_30_last_year) { Time.zone.local(THIS_YEAR - 1, 11, 30) }
  let(:nov_29_next_year) { Time.zone.local(THIS_YEAR + 1, 11, 29) }
  let(:nov_30_next_year) { Time.zone.local(THIS_YEAR + 1, 11, 30) }

  let(:lastyear_dec_2) { Time.zone.local(THIS_YEAR - 1, 12, 2) }


  let(:user_pays_every_nov30) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(nov_30_last_year) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: User.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: Company.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year branding')
    end

    Timecop.freeze(nov_30) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30,
             expire_date: User.expire_date_for_start_date(nov_30),
             notes:       'nov_30 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30,
             expire_date: Company.expire_date_for_start_date(nov_30),
             notes:       'nov_30 branding')
    end

    u
  end


  let(:user_paid_only_lastyear_dec_2) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    Timecop.freeze(lastyear_dec_2) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_2,
             expire_date: User.expire_date_for_start_date(lastyear_dec_2),
             notes:       'lastyear_dec_2 membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  lastyear_dec_2,
             expire_date: Company.expire_date_for_start_date(lastyear_dec_2),
             notes:       'lastyear_dec_2 branding')
    end
    u
  end


  let(:user_unsuccessful_this_year) do
    u    = create(:member_with_membership_app)
    u_co = u.shf_application.companies.first

    # success on nov 30 last year
    Timecop.freeze(nov_30_last_year) do
      create(:membership_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: User.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year success membership')
      create(:h_branding_fee_payment,
             :successful,
             user:        u,
             company:     u_co,
             start_date:  nov_30_last_year,
             expire_date: Company.expire_date_for_start_date(nov_30_last_year),
             notes:       'nov_30_last_year success branding')
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

  let(:company__unsuccessful_this_year) { user_unsuccessful_this_year.shf_application.companies.first }


  let(:user_no_payments)     { create(:user) }
  let(:company_no_payments)  { create(:company) }

  around(:each) do |example|
    Timecop.freeze(dec_1)
    example.run
    Timecop.return
  end


  describe '#most_recent_payment' do

    it 'if no payments, returns nil' do
      expect(user_no_payments.most_recent_payment(Payment::PAYMENT_TYPE_MEMBER)).to be_nil
      expect(user_no_payments.most_recent_payment(Payment::PAYMENT_TYPE_BRANDING)).to be_nil
    end

    it 'most recent is based on created_date' do
      most_recent_membership_payment = user_pays_every_nov30.most_recent_payment(Payment::PAYMENT_TYPE_MEMBER)
      expect(most_recent_membership_payment.created_at).to eq(nov_30)
      most_recent_membership_payment = user_pays_every_nov30.most_recent_payment(Payment::PAYMENT_TYPE_BRANDING)
      expect(most_recent_membership_payment.created_at).to eq(nov_30)
    end

  end


  describe '#payment_start_date' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_start_date(Payment::PAYMENT_TYPE_MEMBER)).to be_nil
      expect(user_no_payments.payment_start_date(Payment::PAYMENT_TYPE_BRANDING)).to be_nil
    end

    it 'is the start_date (Date) of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_start_date(Payment::PAYMENT_TYPE_MEMBER)
      expect(most_recent_membership_payment).to eq(nov_30)
      most_recent_membership_payment = user_pays_every_nov30.payment_start_date(Payment::PAYMENT_TYPE_BRANDING)
      expect(most_recent_membership_payment).to eq(nov_30)
    end
  end


  describe '#payment_expire_date' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_expire_date(Payment::PAYMENT_TYPE_MEMBER)).to be_nil
      expect(user_no_payments.payment_expire_date(Payment::PAYMENT_TYPE_BRANDING)).to be_nil
    end

    it 'is the expire_date (Date) of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_expire_date(Payment::PAYMENT_TYPE_MEMBER)
      expect(most_recent_membership_payment).to eq(nov_29_next_year)
      most_recent_membership_payment = user_pays_every_nov30.payment_expire_date(Payment::PAYMENT_TYPE_BRANDING)
      expect(most_recent_membership_payment).to eq(nov_29_next_year)
    end
  end


  describe '#payment_notes' do

    it 'is nil if no payments' do
      expect(user_no_payments.payment_notes(Payment::PAYMENT_TYPE_MEMBER)).to be_nil
      expect(user_no_payments.payment_notes(Payment::PAYMENT_TYPE_BRANDING)).to be_nil
    end

    it 'is the notes of the most recent payment' do
      most_recent_membership_payment = user_pays_every_nov30.payment_notes(Payment::PAYMENT_TYPE_MEMBER)
      expect(most_recent_membership_payment).to eq('nov_30 membership')
      most_recent_membership_payment = user_pays_every_nov30.payment_notes(Payment::PAYMENT_TYPE_BRANDING)
      expect(most_recent_membership_payment).to eq('nov_30 branding')
    end
  end


  describe '.next_payment_dates returns an Array of [start_date, expire_date] for the next payment for the given entity id' do

    context 'entity not found raises ActiveRecord::RecordNotFound because it signals a problem in the program logic' do
      it 'User (membership fee and branding fee)' do
        expect { described_class.next_payment_dates(100, Payment::PAYMENT_TYPE_MEMBER) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { described_class.next_payment_dates(100, Payment::PAYMENT_TYPE_BRANDING) }.to raise_error(ActiveRecord::RecordNotFound)
      end
      it 'Company (branding fee)' do
        expect { described_class.next_payment_dates(100, Payment::PAYMENT_TYPE_BRANDING) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end


    context 'entity found' do

      context 'no payments' do

        describe 'start_date = Today, expire_date = expire_date_for_start_date(start_date)' do

          context 'User (membership fee and branding fee)' do
            it 'start date = today, expire date = calculated based on today' do
              expect(User.next_payment_dates(user_no_payments.id, Payment::PAYMENT_TYPE_MEMBER)).to eq [dec_1, nov_30_next_year]
              expect(User.next_payment_dates(user_no_payments.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
            end
          end

          context 'Company (branding fee)' do
            it 'start date = today, expire date = calculated based on today' do
              expect(Company.next_payment_dates(company_no_payments.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
            end
          end

        end # describe 'start_date = Today, expire_date = expire_date_for_start_date(start_date)'
      end # context 'no payments'


      context 'has payments' do

        context 'User (membership fee and branding fee)' do

          it 'occurs in the past' do
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, Payment::PAYMENT_TYPE_MEMBER)).to eq [dec_1, nov_30_next_year]
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
          end

          it 'occurs in the future' do
            expect(User.next_payment_dates(user_pays_every_nov30.id, Payment::PAYMENT_TYPE_MEMBER)).to eq [nov_30_next_year, Date.new(THIS_YEAR+2, 11,29)]
            expect(User.next_payment_dates(user_pays_every_nov30.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [nov_30_next_year, Date.new(THIS_YEAR+2, 11,29)]
          end
        end

        context 'Company (branding fee)' do
          it 'occurs in the past' do
            expect(User.next_payment_dates(user_paid_only_lastyear_dec_2.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
          end

          it 'occurs in the future' do
            expect(User.next_payment_dates(user_pays_every_nov30.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [nov_30_next_year, Date.new(THIS_YEAR+2, 11,29)]
          end
        end


        describe 'only uses the successful payments' do

          it 'User membership fee and branding fee' do
            expect(User.next_payment_dates(user_unsuccessful_this_year.id, Payment::PAYMENT_TYPE_MEMBER)).to eq [dec_1, nov_30_next_year]
            expect(User.next_payment_dates(user_unsuccessful_this_year.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
          end

          it 'Company branding fee' do
            expect(Company.next_payment_dates(company__unsuccessful_this_year.id, Payment::PAYMENT_TYPE_BRANDING)).to eq [dec_1, nov_30_next_year]
          end

        end

        describe 'what if you pass PAYMENT_TYPE_MEMBER for a Company?' do
          pending
        end

      end
    end
  end


  describe '.expire_date_for_start_date' do

    it 'is 1 calendar year minus 1 day' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(THIS_YEAR, 1, 1))
      expect(computed).to eq Time.zone.local(THIS_YEAR, 12, 31)
    end

    it 'leap year' do
      computed = described_class.expire_date_for_start_date(Time.zone.local(THIS_YEAR + 2, 2, 1))
      expect(computed).to eq Time.zone.local(THIS_YEAR + 3, 1, 31)
    end

  end

end
