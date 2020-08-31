require 'rails_helper'

RSpec.describe PaymentCoveringYear do
  let(:given_year) { 2000 }

  describe 'initialize' do
    it 'default year is the current year' do
      expect(described_class.new.year).to eq(Time.zone.today.year)
    end

    it 'default payment is a new Payment' do
      expect(described_class.new.payment).to be_a(Payment)
    end

    it 'can provide the specific year for the calculations' do
      expect(described_class.new(year: given_year).year).to eq(given_year)
    end
  end

  describe 'payment_amount' do

    describe 'the payment amount is based on the payment type' do

      it 'membership fee' do
        expect(described_class).to receive(:membership_fee_amount).and_return(100)
        described_class.new(payment: build(:membership_fee_payment)).payment_amount
      end

      it 'branding license fee' do
        expect(described_class).to receive(:branding_license_fee_amount).and_return(100)
        described_class.new(payment: build(:h_branding_fee_payment)).payment_amount
      end
    end

    it 'is in 100s of SEK (divides the payment by 100)' do
      expect(described_class.new(payment: build(:membership_fee_payment)).payment_amount).to eq(described_class.membership_fee_amount / 100)
    end
  end


  describe 'days_paid_for_year' do
    it 'muliplies the (SEK per day) amount times the number of days covered in the year' do
      expect(subject).to receive(:sek_per_day).and_return(2)
      expect(subject).to receive(:num_days_of_year_covered).and_return(3)

      expect(subject.days_paid_for_year).to eq(6)
    end

    it 'rounds to 2 decimal places' do
      allow(subject).to receive(:sek_per_day).and_return(0.3363)
      allow(subject).to receive(:num_days_of_year_covered).and_return(1)
      expect(subject.days_paid_for_year).to eq(0.34)
    end
  end

  describe 'sek_per_day' do
    it 'divides the payment amount by the total number of days paid' do
      expect(subject).to receive(:payment_amount).and_return(6)
      expect(subject).to receive(:total_number_of_days_paid).and_return(3)

      expect(subject.sek_per_day).to eq(2)
    end

    it 'rounds to 2 decimal places' do
      allow(subject).to receive(:payment_amount).and_return(2)
      allow(subject).to receive(:total_number_of_days_paid).and_return(3)

      expect(subject.sek_per_day).to eq(0.67)
    end
  end


  describe 'percent_of_year_covered' do
    it 'is 100 if the payment covers more than the year given' do
      allow(subject).to receive(:payment_covers_more_than_year?).and_return(true)
      expect(subject.percent_of_year_covered).to eq 100
    end

    it 'else is (num days covered by the Payment) / days in the year' do
      allow(subject).to receive(:payment_covers_more_than_year?).and_return(false)
      expect(subject).to receive(:num_days_of_year_covered).and_return(30)
      expect(subject).to receive(:days_in_year).and_return(120)

      expect(subject.percent_of_year_covered).to eq 25
    end

    it 'rounds to 2 decimal places' do
      allow(subject).to receive(:payment_covers_more_than_year?).and_return(false)
      allow(subject).to receive(:num_days_of_year_covered).and_return(59)
      allow(subject).to receive(:days_in_year).and_return(120)

      expect(subject.percent_of_year_covered).to eq 49.17
    end
  end

  describe 'total_number_of_days_paid' do
    it 'payment expiration date - payment start date + 1' do
      expect(subject.payment).to receive(:start_date).and_return(Date.current - 2)
      expect(subject.payment).to receive(:expire_date).and_return(Date.current)

      expect(subject.total_number_of_days_paid).to eq 3
    end
  end


  describe 'num_days_of_year_covered' do

    it 'all the days in this year if the payment covers more than the year given' do
      expect(subject).to receive(:payment_covers_more_than_year?).and_return(true)

      expect(subject.num_days_of_year_covered).to eq(subject.days_in_year)
    end

    it 'is the number of days covered in the year' do
      membership_payment = build(:membership_fee_payment,
                                 start_date: Date.new(given_year, 1, 1),
                                 expire_date: Date.new(given_year, 1, 12))
      pay_covering_year = described_class.new(payment: membership_payment, year: given_year)
      expect(pay_covering_year.num_days_of_year_covered).to eq 12
    end

    it 'the ending date counts as a full day' do
      membership_payment = build(:membership_fee_payment,
                                 start_date: Date.new(given_year, 1, 1),
                                 expire_date: Date.new(given_year, 1, 1))
      pay_covering_year = described_class.new(payment: membership_payment, year: given_year)
      expect(pay_covering_year.num_days_of_year_covered).to eq 1
    end
  end

  describe 'payment_covers_more_than_year?' do

    context 'payment starts before the start of the year' do
      let(:start_before_year_date) { Date.new(given_year - 1, 12, 31) }

      context 'payment ends on or before the end of the year' do
        it 'false if payment ends before the end of the year' do
          expect(described_class.new(payment: build(:membership_fee_payment,
                                                    start_date: start_before_year_date,
                                                    expire_date: Date.new(given_year, 12, 30)),
                                     year: given_year)
                   .payment_covers_more_than_year?).to be_falsey
        end

        it 'false if payment ends on the last day of the year' do
          expect(described_class.new(payment: build(:membership_fee_payment,
                                                    start_date: start_before_year_date,
                                                    expire_date: Date.new(given_year, 12, 31)),
                                     year: given_year)
                   .payment_covers_more_than_year?).to be_falsey
        end
      end

      context 'payment ends after the last day of the year' do
        it 'true' do
          expect(described_class.new(payment: build(:membership_fee_payment,
                                                    start_date: start_before_year_date,
                                                    expire_date: Date.new(given_year + 1, 1, 1)),
                                        year: given_year)
                   .payment_covers_more_than_year?).to be_truthy
        end
      end
    end

    context 'always false if payment starts on or after the start of the year' do

      context 'starts on the first day of the year' do
        let(:start_date_on_year_start) { Date.new(given_year, 1, 1) }

          it 'false if payment ends before the end of the year' do
            expect(described_class.new(payment: build(:membership_fee_payment,
                                                      start_date: start_date_on_year_start,
                                                      expire_date: Date.new(given_year, 12, 30)),
                                       year: given_year)
                     .payment_covers_more_than_year?).to be_falsey
          end

          it 'false if payment ends on the last day of the year' do
            expect(described_class.new(payment: build(:membership_fee_payment,
                                                      start_date: start_date_on_year_start,
                                                      expire_date: Date.new(given_year, 12, 31)),
                                       year: given_year)
                     .payment_covers_more_than_year?).to be_falsey
          end

        it 'false if payment ends after the last day of the year' do
            expect(described_class.new(payment: build(:membership_fee_payment,
                                                      start_date: start_date_on_year_start,
                                                      expire_date: Date.new(given_year + 1, 1, 1)),
                                       year: given_year)
                     .payment_covers_more_than_year?).to be_falsey

        end
      end

      context 'starts after the first day of the year' do
        let(:start_date_after_year_start) { Date.new(given_year, 1, 2) }

        it 'false if payment ends before the end of the year' do
          expect(described_class.new(payment: build(:membership_fee_payment,
                                                    start_date: start_date_after_year_start,
                                                    expire_date: Date.new(given_year, 12, 30)),
                                     year: given_year)
                   .payment_covers_more_than_year?).to be_falsey
        end

        it 'false if payment ends on the last day of the year' do
          expect(described_class.new(payment: build(:membership_fee_payment,
                                                    start_date: start_date_after_year_start,
                                                    expire_date: Date.new(given_year, 12, 31)),
                                     year: given_year)
                   .payment_covers_more_than_year?).to be_falsey
        end

        it 'false if payment ends after the last day of the year' do
          expect(described_class.new(payment: build(:membership_fee_payment,
                                                    start_date: start_date_after_year_start,
                                                    expire_date: Date.new(given_year + 1, 1, 1)),
                                     year: given_year)
                   .payment_covers_more_than_year?).to be_falsey
        end
      end
    end

  end


  describe 'days_in_year' do
    it 'is the number of days in the year' do
      expect(described_class.new(year: 2001).days_in_year).to eq 365
    end

    it 'handles a leap year' do
      expect(described_class.new(year: given_year).days_in_year).to eq 366
    end
  end
end
