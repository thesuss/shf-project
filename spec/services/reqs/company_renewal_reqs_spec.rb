# frozen_string_literal: true

require 'rails_helper'

module Reqs
  RSpec.describe CompanyRenewalReqs do
    let(:subject) { CompanyRenewalReqs }

    let(:yesterday) { Date.current - 1.day }
    let(:company) { build(:company) }
    let(:current_member) { build(:company, membership_status: 'current_member') }
    let(:member_in_grace_pd) do
      grace_company = build(:company, last_day: yesterday, membership_status: 'in_grace_period')
      allow(grace_company).to receive(:most_recent_membership).and_return(build(:company_membership))
      grace_company
    end

    # All membership statuses that are not current_member or in grace period
    STATUSES_NOT_CURRENT_OR_GRACE_PD =
      Company.membership_statuses - [Company::STATE_CURRENT_MEMBER, Company::STATE_IN_GRACE_PERIOD]

    describe 'specifications and Unit Tests' do

      describe '.requirements_excluding_payments_met?' do
        it 'first resets the failed requirements so the list is empty' do
          expect(described_class).to receive(:reset_failed_requirements)
          described_class.requirements_excluding_payments_met?(company)
        end

        it 'wraps each method call in record_requirement_failure' do
          allow(company).to receive(:may_renew?).and_return(true)
          allow(company).to receive(:valid_date_for_renewal?).and_return(true)

          allow(described_class).to receive(:record_failure)
          allow(described_class).to receive(:current_membership_short_str).with(company).and_return('[current membership info]')
          allow(described_class).to receive(:most_recent_membership_short_str).with(company).and_return('[most recent membership info]')

          today = Date.current
          expect(described_class).to receive(:record_requirement_failure)
                                       .with(company, :may_renew?, nil, 'cannot renew based on the current membership status (status: not_a_member)').and_call_original
          expect(described_class).to receive(:record_requirement_failure)
                                       .with(company, :valid_date_for_renewal?, today, "#{today} is not a valid renewal date ([current membership info])").and_call_original

          described_class.requirements_excluding_payments_met?(company)
        end

        it 'checks state machine to confirm membership_status is in the correct state to call the renew event' do
          expect(company).to receive(:may_renew?).and_return(true)
          subject.requirements_excluding_payments_met?(company)
        end

        it 'false if company cannot renew based on the current membership status' do
          allow(company).to receive(:may_renew?).and_return(false)
          expect(subject.requirements_excluding_payments_met?(company)).to be_falsey
        end

        it 'false if company cannot renew on the given date' do
          expect(company).to receive(:valid_date_for_renewal?).and_return(false)
          expect(subject.requirements_excluding_payments_met?(company)).to be_falsey
        end

        context 'company can renew based on the current membership_status' do
          before(:each) { allow(company).to receive(:may_renew?).and_return(true) }

          it 'true if company can renew on the given date' do
            expect(company).to receive(:valid_date_for_renewal?).and_return(true)
            expect(subject.requirements_excluding_payments_met?(company)).to be_truthy
          end
        end
      end
    end
    # ------------------------------------------------------------------------------------------

    # @todo Are any of these really needed?  can things be mocked or stubbed?
    describe 'Integration tests' do

      describe '.requirements_met?' do
        let(:member) { build(:company) }
        let(:days_can_renew_early) { 5 }

        before(:each) { allow(Memberships::MembershipsManager).to receive(:days_can_renew_early).and_return(days_can_renew_early) }

        it 'always false if has never made a payment' do
          expect(subject.requirements_met?({ entity: build(:company) })).to be_falsey
        end

        context 'is a current member' do
          let(:last_day) { Date.current + 100 }
          let(:current_member) { create(:member_with_expiration_date, expiration_date: last_day) }

          it 'true if not too early to renew' do
            # set today to a day that the member can renew early
            travel_to(last_day - days_can_renew_early + 2) do
              expect(current_member.valid_date_for_renewal?(Date.current)).to be_truthy
              expect(subject.requirements_excluding_payments_met?(current_member)).to be_truthy
              expect(subject.payment_requirements_met?(current_member)).to be_truthy

              expect(subject.requirements_met?({ entity: current_member })).to be_truthy
            end
          end

          it 'false if too early to renew' do
            # set today to a day that is too early to renew
            travel_to(last_day - days_can_renew_early - 2) do
              expect(current_member.today_is_valid_renewal_date?).to be_falsey
              expect(subject.requirements_met?({ entity: current_member })).to be_falsey
            end
          end
        end

        context 'membership has expired' do

          it 'false if member is no longer a member; (past the in grace period)' do
            grace_period_length = 4.days
            allow(Memberships::MembershipsManager).to receive(:grace_period).and_return(grace_period_length)
            former_member = create(:member_with_expiration_date, expiration_date: yesterday)

            allow(former_member).to receive(:current_member?).and_return(false)
            allow(former_member).to receive(:in_grace_period?).and_return(false)
            allow(former_member).to receive(:former_member?).and_return(true)

            # set today to a date that is past the grace period
            travel_to(Date.current + grace_period_length + 1.day) do
              expect(subject.requirements_met?({ entity: former_member })).to be_falsey
            end
          end
        end
      end

      describe '.requirements_excluding_payments_met?' do

        # Data is based on production data from approx Nov 2, 2021

        # Create <number of weeks> members, 1 per week starting on the given start date. (default start date = 1 January of the given year)
        def create_members_every_week(number_of_weeks = 52, start_date = Date.new(Date.current.year, 1, 1), company_number: 6759139469)
          next_date = start_date
          number_of_weeks.times do
            # puts "[#{week_num}] next_date: #{next_date} #{next_date.strftime('%A')}"
            m = create(:member, first_day: next_date, company_number: company_number)
            m.update(membership_status: Company::STATE_CURRENT_MEMBER, membership_number: m.id)
            next_date += 1.week
          end
        end

        # See if each member in the given list can renew on the given date and put the result into a list.
        # Return a list of results for all of the given members
        def can_renew_results(members_to_renew, renewal_date = Date.current)
          renewal_results = []
          (members_to_renew).each do |u|
            req_result = requirements_for_renewal.requirements_excluding_payments_met?(u, renewal_date)
            renewal_results << {
              company_id: u.id,
              result: req_result,
              failure_reason: u.requirements_for_renewal.failed_requirements
            }
          end
          renewal_results
        end

        # show a compact summary of the renewal results
        def renewal_results_summary(renewal_results = [])
          summary = ''
          can_renew = 'can renew'
          cannot_renew = "cannot renew"
          renewal_results.each do |result|
            renewable = result[:result] ? can_renew : cannot_renew
            output = "Company [#{result[:company_id]}] #{Company.find(result[:company_id]).membership_status} #{renewable}"
            unless result[:result]

              output << ':  ' + result[:failure_reason].map { |reason| reason[:string] }.join('; ')
            end
            summary << output + "\n"
          end
          summary
        end

        let(:company) { create(:company) }

        let(:members_to_renew) { (Company.current_member + Company.in_grace_period).sort_by(&:id) }
        let(:renewal_date) { Date.new(2021, 12, 1) }

        xit 'right number of those that can/not renew' do

          current_member_status = Company::STATE_CURRENT_MEMBER

          # the grace period is 1 year
          # The number of days before the last day that someone can renew is 90 days.
          # Be sure to test all of the variations of when someone could have agreed to the membership

          allow(AdminOnly::AppConfiguration.instance).to receive(:membership_expiring_soon_days).and_return(90)
          allow(AdminOnly::AppConfiguration.instance).to receive(:membership_expired_grace_period_duration).and_return(ActiveSupport::Duration.parse('P1Y'))

          # puts "membership_expiring_soon_days: #{AdminOnly::AppConfiguration.instance.membership_expiring_soon_days}"
          # puts "membership_expired_grace_period_duration: #{AdminOnly::AppConfiguration.instance.membership_expired_grace_period_duration.parts}"
          # puts "membership_guidelines_required_date: #{CompanyChecklistManager.membership_guidelines_required_date}"

          june1_2021 = Date.new(2021, 6, 1)
          june2_2021 = Date.new(2021, 6, 2)
          june3_2021 = Date.new(2021, 6, 3)
          june4_2021 = Date.new(2021, 6, 4)

          travel_to(june1_2021 - 1.year + 1.day) do
            create(:member, last_day: june1_2021, email: 'in_grace_pd_can_renew@example.com',
                   company_number: company.company_number, membership_status: current_member_status)
          end
          last_day_2021_06_01 = Company.find_by(email: 'in_grace_pd_can_renew@example.com')
          upload = create(:uploaded_file, :txt, company: last_day_2021_06_01)
          upload.update(created_at: june1_2021)
          upload = create(:uploaded_file, :txt, company: last_day_2021_06_01)
          upload.update(created_at: june1_2021 + 1.day)
          guidelines_in_grace_pd = CompanyChecklistManager.find_or_create_after_latest_membership_last_day(last_day_2021_06_01)
          guidelines_in_grace_pd&.set_complete_including_children(june1_2021 + 1.day)

          travel_to(june2_2021 - 1.year + 1.day) do
            create(:member, last_day: june2_2021, email: 'in_grace_pd_missing_uploads@example.com',
                   company_number: company.company_number, membership_status: current_member_status)
          end
          last_day_2021_06_02 = Company.find_by(email: 'in_grace_pd_missing_uploads@example.com')
          upload = create(:uploaded_file, :txt, company: last_day_2021_06_02)
          upload.update(created_at: june2_2021)
          guidelines_in_grace_pd = CompanyChecklistManager.find_or_create_after_latest_membership_last_day(last_day_2021_06_02)
          guidelines_in_grace_pd&.set_complete_including_children(june2_2021 + 1.day)

          travel_to(june3_2021 - 1.year + 1.day) do
            create(:member, last_day: june3_2021, email: 'in_grace_pd_missing_guidelines@example.com',
                   company_number: company.company_number, membership_status: current_member_status)
          end
          last_day_2021_06_03 = Company.find_by(email: 'in_grace_pd_missing_guidelines@example.com')
          upload = create(:uploaded_file, :txt, company: last_day_2021_06_03)
          upload.update(created_at: june3_2021)
          upload = create(:uploaded_file, :txt, company: last_day_2021_06_03)
          upload.update(created_at: (june3_2021 + 1.day))

          travel_to(june4_2021 - 1.year + 1.day) do
            create(:member, last_day: june4_2021, email: 'in_grace_pd_missing_uploads_and_guidelines@example.com',
                   company_number: company.company_number, membership_status: current_member_status)
          end
          last_day_2021_06_04 = Company.find_by(email: 'in_grace_pd_missing_uploads_and_guidelines@example.com')
          upload = create(:uploaded_file, :txt, company: last_day_2021_06_04)
          upload.update(created_at: june4_2021)

          # Creeate members that agreed to the Membership guidelines :
          #  - agreed before renewals were implemented, and perhaps before the current membership started
          jan2 = Date.new(Date.current.year, 1, 2)
          agreed_before_renewals_implemented = create(:member, first_day: jan2, company_number: company.company_number)
          agreed_before_renewals_implemented.uploaded_files.each { |f| f.update(created_at: jan2) }
          agreed_before_renewals_implemented.update(membership_status: Company::STATE_CURRENT_MEMBER, membership_number: agreed_before_renewals_implemented.id)
          CompanyChecklistManager.most_recent_membership_guidelines_list_for(agreed_before_renewals_implemented)&.set_complete_including_children(CompanyChecklistManager.membership_guidelines_required_date - 1.day)

          # Paid for 2 memberships at once ( = paid for 1 in advance)
          last_year = Date.current.year - 1
          jan1_last_year = Date.new(last_year, 1, 1)
          jan1 = Date.new(Date.current.year, 1, 1)
          dec31_next_year = jan1 + 1.year - 1.day

          travel_to jan1_last_year do
            paid_for_2 = create(:member, first_day: jan1_last_year, company_number: company.company_number,
                                email: 'paid-for-2@example.com')
            paid_for_2.uploaded_files.each { |f| f.update(created_at: jan1_last_year) }
            paid_for_2.update(membership_status: Company::STATE_CURRENT_MEMBER, membership_number: paid_for_2.id)
            # pays for 2 years:
            paid_for_2.payments.member_fee.first.update(expire_date: dec31_next_year)
          end

          paid_for_2 = Company.find_by(email: 'paid-for-2@example.com')
          travel_to jan1 do
            create(:company_membership, owner: paid_for_2, first_day: jan1, last_day: (jan1 + 1.year - 1.day))
          end

          travel_to (jan1 + 11.months) do
            AdminOnly::CompanyChecklistFactory.create_member_guidelines_checklist_for(paid_for_2)
            CompanyChecklistManager.most_recent_membership_guidelines_list_for(paid_for_2)&.set_complete_including_children(Date.current)
            create(:uploaded_file, :txt, company: paid_for_2)
          end

          # The first 5 of these will be able to renew. The last 2 will not because it is too early for them to renew.
          create_members_every_week(7, company_number: company.company_number) # creates 52 members starting 1 jan of this year

          travel_to renewal_date do
            Company.all.each do |company|
              MembershipStatusUpdater.instance.update_membership_status(company, send_email: false)
            end
          end

          # puts "#{Company.count} total Companys"
          # puts "#{Company.in_grace_period.count} in_grace_period"
          # puts "#{Company.current_member.count} current_member"
          #
          # puts "======================"

          members_to_renew = (Company.current_member + Company.in_grace_period).sort_by(&:id)
          # puts "members not current_member or in_grace_period:"
          # (Company.all - Company.current_member - Company.in_grace_period).each do |u|
          #   pp u
          #   # u.memberships.each{|m| pp m}
          # end
          # puts "======================"

          expect(members_to_renew.count).to eq 13

          renew_results = can_renew_results(members_to_renew, renewal_date)
          # puts renewal_results_summary(renew_results)

          expect(renew_results.select { |results| results[:result] }.count).to eq(8) # can renew
          expect(renew_results.reject { |results| results[:result] }.count).to eq(5) # these are too early to renew
        end

      end
    end
  end
end
