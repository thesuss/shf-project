require 'rails_helper'

RSpec.describe RequirementsForRenewal, type: :model do

  let(:subject) { RequirementsForRenewal }

  let(:yesterday) { Date.current - 1.day }
  let(:user) { build(:user) }
  let(:current_member) { build(:member, membership_status: 'current_member') }
  let(:member_in_grace_pd) do
    grace_user = build(:member, last_day: yesterday, membership_status: 'in_grace_period')
    allow(grace_user).to receive(:most_recent_membership).and_return(build(:membership))
    grace_user
  end

  # All user membership statuses that are not current_member or in grace period
  STATUSES_NOT_CURRENT_OR_GRACE_PD =
    User.membership_statuses - [User::STATE_CURRENT_MEMBER, User::STATE_IN_GRACE_PERIOD]


  describe 'specifications and Unit Tests' do

    before(:each) do
      # stub this so we don't have to create the MasterChecklist for the Member Guidelines checklist
      # if a ShfApplication is accepted.
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for).and_return(true)
    end

    describe '.requirements_excluding_payments_met?' do

      it 'first resets the failed requirements so the list is empty' do
        expect(described_class).to receive(:reset_failed_requirements)
        described_class.requirements_excluding_payments_met?(user)
      end

      it 'wraps each method call in record_requirement_failure' do
        allow(user).to receive(:may_renew?).and_return(true)
        allow(user).to receive(:valid_date_for_renewal?).and_return(true)
        allow(user).to receive(:has_approved_shf_application?).and_return(true)
        allow(described_class).to receive(:agreed_to_membership_terms?).and_return(true)
        allow(described_class).to receive(:docs_uploaded?).and_return(true)
        allow(described_class).to receive(:record_failure)
        allow(described_class).to receive(:current_membership_short_str).with(user).and_return('[current membership info]')
        allow(described_class).to receive(:most_recent_membership_short_str).with(user).and_return('[most recent membership info]')

        today = Date.current
        expect(described_class).to receive(:record_requirement_failure)
                                     .with(user, :may_renew?, nil, 'cannot renew based on the current membership status (status: not_a_member)').and_call_original
        expect(described_class).to receive(:record_requirement_failure)
                                     .with(user, :valid_date_for_renewal?, today,"#{today} is not a valid renewal date ([current membership info])").and_call_original
        expect(described_class).to receive(:record_requirement_failure)
                                     .with(user, :has_approved_shf_application?, nil, "no approved application").and_call_original
        expect(described_class).to receive(:record_requirement_failure)
                                     .with(described_class, :agreed_to_membership_terms?, user, "has not agreed to membership terms within the right time period ([most recent membership info]; [current membership info]; last agreed to: )").and_call_original
        expect(described_class).to receive(:record_requirement_failure)
                                     .with(described_class, :docs_uploaded?, user, "no uploaded documents within the right time period ([most recent membership info]; [current membership info]; most recent upload created_at: )").and_call_original

        described_class.requirements_excluding_payments_met?(user)
      end


      it 'checks state machine to confirm membership_status is in the correct state to call the renew event' do
        expect(user).to receive(:may_renew?).and_return(true)
        subject.requirements_excluding_payments_met?(user)
      end

      it 'false if state machine says it cannot do the renew event (membership_status is in the wrong state)' do
        allow(user).to receive(:may_renew?).and_return(false)

        expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
      end

      context 'user can renew on the given date' do
        before(:each) { allow(user).to receive(:may_renew?).and_return(true) }

        context 'user can renew on the given date' do
          before(:each) do
            allow(user).to receive(:current_member?).and_return(true)
            allow(user).to receive(:valid_date_for_renewal?).and_return(true)
          end

          context 'user has an approved SHF application' do
            before(:each) { allow(user).to receive(:has_approved_shf_application?).and_return(true) }

            context 'user has agreed to the membership guidelines within the right time period' do
              before(:each) { allow(subject).to receive(:agreed_to_membership_terms?).and_return(true) }

              it 'true if documents have been uploaded in the right time period' do
                allow(subject).to receive(:docs_uploaded?).and_return(true)
                expect(subject.requirements_excluding_payments_met?(user)).to be_truthy
              end

              it 'false if documents have not been uploaded in the right time period' do
                allow(subject).to receive(:docs_uploaded?).and_return(false)
                expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
              end
            end

            it 'false if the user has not agreed to the membership guidelines within the right time period' do
              allow(subject).to receive(:docs_uploaded?).and_return(true)
              expect(subject).to receive(:agreed_to_membership_terms?).and_return(false)
              expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
            end
          end

          it 'false if user does not have an approved SHF application' do
            allow(subject).to receive(:agreed_to_membership_terms?).and_return(true)
            allow(subject).to receive(:docs_uploaded?).and_return(true)

            expect(user).to receive(:has_approved_shf_application?).and_return(false)
            expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
          end
        end

        it 'false if user cannot renew on the given date' do
          allow(user).to receive(:has_approved_shf_application?).and_return(true)
          allow(subject).to receive(:agreed_to_membership_terms?).and_return(true)
          allow(subject).to receive(:docs_uploaded?).and_return(true)

          expect(user).to receive(:valid_date_for_renewal?).and_return(false)
          expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
        end
      end

      it 'false if user cannot renew' do
        allow(user).to receive(:may_renew?).and_return(false)

        expect(subject.requirements_excluding_payments_met?(user)).to be_falsey
      end
    end

    describe '.current_membership_short_str' do
      it 'calls .short_membership_str with the current membership for the given user' do
        faux_membership = build(:membership, user: user)
        allow(user).to receive(:current_membership).and_return(faux_membership)
        expect(described_class).to receive(:short_membership_str).with(faux_membership)
        described_class.current_membership_short_str(user)
      end
    end

    describe '.most_recent_membership_short_str' do
      it 'calls .short_membership_str with the current membership for the given user' do
        faux_membership = build(:membership, user: user)
        allow(user).to receive(:current_membership).and_return(nil)
        allow(user).to receive(:most_recent_membership).and_return(faux_membership)
        expect(described_class).to receive(:short_membership_str).with(faux_membership)
        described_class.most_recent_membership_short_str(user)
      end
    end

    describe '.short_membership_str' do
      it "is 'nil' if the membership is nil" do
        expect(described_class.short_membership_str(nil)).to eq('nil')
      end

      it "is 'membership_id: first_day - last_day'" do
        faux_membership = create(:membership, user: user)
        first_day = faux_membership.first_day.strftime('%Y-%m-%d') 
        last_day = faux_membership.last_day.strftime('%Y-%m-%d') 
        expect(described_class.short_membership_str(faux_membership)).to match(/\[(\d)+\] #{first_day} - #{last_day}/)
      end
    end


    describe '.docs_uploaded?' do

      context 'is a current member' do

        it 'true if files have been uploaded on or after the first day of the current membership term' do
          expect(current_member).to receive(:file_uploaded_during_this_membership_term?)
                                      .and_return(true)
          expect(subject.docs_uploaded?(current_member)).to be_truthy
        end

        it 'false if files were not uploaded during the current membership term' do
          expect(current_member).to receive(:file_uploaded_during_this_membership_term?)
                                      .and_return(false)
          expect(subject.docs_uploaded?(current_member)).to be_falsey
        end
      end

      context 'is in the grace period' do

        it 'true if files have been uploaded since the last day of the membership' do
          expect(member_in_grace_pd).to receive(:file_uploaded_on_or_after?)
                                          .and_return(true)
          expect(subject.docs_uploaded?(member_in_grace_pd)).to be_truthy
        end

        it 'false if files were not uploaded since the last day of the membership' do
          expect(member_in_grace_pd).to receive(:file_uploaded_on_or_after?)
                                          .and_return(false)
          expect(subject.docs_uploaded?(member_in_grace_pd)).to be_falsey
        end
      end

      context 'all other membership statuses' do

        describe 'is always false ' do

          STATUSES_NOT_CURRENT_OR_GRACE_PD.each do |status|
            it "membership status: #{status}" do
              user = build(:user, membership_status: status)
              expect(subject.docs_uploaded?(user)).to be_falsey
            end
          end
        end
      end
    end


    describe '.docs_uploaded_for_renewal' do

      context 'is current member' do
        it 'calls files_uploaded_during_this_membership for the current member' do
          expect(current_member).to receive(:files_uploaded_during_this_membership)
                                      .and_return(true)
          subject.docs_uploaded_for_renewal(current_member)
        end
      end

      context 'membership status is in the grace period' do
        it 'calls files_uploaded_on_or_after(1 day after the last day of the most recent membership) for the current member' do
          last_day_of_most_recent = member_in_grace_pd.most_recent_membership.last_day
          expect(member_in_grace_pd).to receive(:files_uploaded_on_or_after)
                                          .with(last_day_of_most_recent + 1.day)
          subject.docs_uploaded_for_renewal(member_in_grace_pd)
        end
      end

      context 'all other membership statuses' do
        describe 'always returns an empty list' do
          STATUSES_NOT_CURRENT_OR_GRACE_PD.each do |status|
            it "membership status: #{status}" do
              user = build(:user, membership_status: status)
              expect(subject.docs_uploaded_for_renewal(user)).to be_empty
            end
          end
        end
      end
    end


    describe '.agreed_to_membership_terms?' do
      it "calls UserChecklistManager.completed_membership_guidelines_checklist_for_renewal? with the user" do
        u = build(:user)
        expect(UserChecklistManager).to receive(:completed_membership_guidelines_checklist_for_renewal?)
                                          .with(u)
        described_class.agreed_to_membership_terms?(u)
      end
    end

    describe '.payment_requirements_met?' do

      it 'true if all payments are current' do
        u = build(:user)
        expect(u).to receive(:payments_current_as_of?).and_return(true)
        expect(subject.payment_requirements_met?(u)).to be_truthy
      end

      it 'false if no payments have been made' do
      u = build(:user)
      expect(subject.payment_requirements_met?(u)).to be_falsey
    end
    end


    describe '.record_requirement_failure' do
      let(:u) { build(:user) }
      let(:given_date) { Date.current }

      it 'calls the method on the object with the method arguments e.g. obj.method(method_args)' do
        expect(u).to receive(:valid_date_for_renewal?)
                      .with(given_date)
                      .and_return(true)
        described_class.record_requirement_failure(u, :valid_date_for_renewal?, given_date,  'string describing the failure')
      end

      context 'result is falsey' do
        before(:each) do
          allow(u).to receive(:valid_date_for_renewal?)
                        .with(given_date)
                        .and_return(false)
        end

        it 'records the failure' do
          expect(described_class).to receive(:record_failure)
                                       .with(:valid_date_for_renewal?, 'string describing the failure', [given_date])
          described_class.record_requirement_failure(u, :valid_date_for_renewal?, given_date,  'string describing the failure')
        end
      end

      it 'returns the result from calling the method' do
        allow(described_class).to receive(:record_failure)

        allow(u).to receive(:valid_date_for_renewal?)
                       .with(given_date)
                       .and_return(true)
        expect(described_class.record_requirement_failure(u, :valid_date_for_renewal?, given_date, 'string describing the failure')).to be_truthy

        allow(u).to receive(:valid_date_for_renewal?)
                      .with(given_date)
                      .and_return(nil)
        expect(described_class.record_requirement_failure(u, :valid_date_for_renewal?, given_date,  'string describing the failure')).to be_nil

        allow(u).to receive(:valid_date_for_renewal?)
                      .with(given_date)
                      .and_return('blorf')
        expect(described_class.record_requirement_failure(u, :valid_date_for_renewal?, given_date,  'string describing the failure')).to eq('blorf')
      end

    end

    describe '.record_failure' do
      it 'appends a Hash of failure info to the list of failed_requirements' do
        described_class.reset_failed_requirements
        described_class.record_failure(:method_name, 'failure string', 1, 2, 3)
        expect(described_class.failed_requirements).to match_array([{method: :method_name,
                                                              string: 'failure string',
                                                              method_args: '[1, 2, 3]'}])
      end
    end

    describe '.failed_requirements' do
      it 'returns the (class) failed requirements' do
        described_class.reset_failed_requirements
        described_class.record_failure(:method_name, 'failure string', 1, 2, 3)
        described_class.record_failure(:method_name, 'failure string2', 12, 22, 32)
        expect(described_class.failed_requirements).to match_array([{method: :method_name,
                                                                     string: 'failure string',
                                                                     method_args: '[1, 2, 3]'},
                                                                    {method: :method_name,
                                                                      string: 'failure string2',
                                                                      method_args: '[12, 22, 32]'}])
      end
    end

    describe '.reset_failed_requirements' do

      it 'sets @@failed_requirements to an empty array' do
        described_class.record_failure(:some_method, 'failure string', [1,2,3])
        expect(described_class.failed_requirements).not_to be_empty
        described_class.reset_failed_requirements
        expect(described_class.failed_requirements).to be_empty
      end
    end
  end
  # ------------------------------------------------------------------------------------------

  # @todo Are any of these really needed?  can things be mocked or stubbed?
  describe 'Integration tests' do

    describe '.requirements_met?' do
      let(:member) { build(:member_with_membership_app) }
      let(:days_can_renew_early) { 5 }

      before(:each) { allow(MembershipsManager).to receive(:days_can_renew_early).and_return(days_can_renew_early) }

      it 'always false if has never made a payment' do
        approved_app = create(:shf_application, :accepted)
        expect(subject.requirements_met?({ user: approved_app.user })).to be_falsey
      end

      context 'has approved application' do

        let(:approved_applicant) do
          approved_app = create(:shf_application, :accepted)
          approved_app.user
        end

        context 'membership guidelines ARE agreed to within the right time period' do
          before(:each) do
            allow(subject).to receive(:agreed_to_membership_terms?).and_return(true)
            allow_any_instance_of(UserChecklist).to receive(:set_complete_including_children)
          end

          context 'file has been uploaded during this membership term' do
            before(:each) { allow(described_class).to receive(:docs_uploaded?).and_return(true) }

            context 'is a current member' do
              let(:last_day) { Date.current + 100 }
              let(:current_member) { create(:member_with_expiration_date, expiration_date: last_day) }

              it 'true if not too early to renew' do
                # set today to a day that the member can renew early
                travel_to(last_day - days_can_renew_early + 2) do
                  expect(current_member.valid_date_for_renewal?(Date.current)).to be_truthy
                  expect(subject.requirements_excluding_payments_met?(current_member)).to be_truthy
                  expect(subject.payment_requirements_met?(current_member)).to be_truthy

                  expect(subject.requirements_met?({ user: current_member })).to be_truthy
                end
              end

              it 'false if too early to renew' do
                # set today to a day that is too early to renew
                travel_to(last_day - days_can_renew_early - 2) do
                  expect(current_member.today_is_valid_renewal_date?).to be_falsey
                  expect(subject.requirements_met?({ user: current_member })).to be_falsey
                end
              end
            end

            context 'membership has expired' do

              it 'false if member is no longer a member; (past the in grace period)' do
                grace_period_length = 4.days
                allow(MembershipsManager).to receive(:grace_period).and_return(grace_period_length)
                former_member = create(:member_with_expiration_date, expiration_date: yesterday)

                allow(former_member).to receive(:current_member?).and_return(false)
                allow(former_member).to receive(:in_grace_period?).and_return(false)
                allow(former_member).to receive(:former_member?).and_return(true)

                # set today to a date that is past the grace period
                travel_to(Date.current + grace_period_length + 1.day) do
                  expect(subject.requirements_met?({ user: former_member })).to be_falsey
                end
              end
            end

            it 'false if membership payment not made' do
              expect(subject.requirements_met?({ user: approved_applicant })).to be_falsey
            end
          end

          context 'no file uploaded during this membership term' do
            it 'always false' do
              allow(described_class).to receive(:docs_uploaded?)
                                          .and_return(false)

              last_day = Date.current + 100
              approved_and_paid = create(:member_with_expiration_date, expiration_date: last_day)

              travel_to(last_day - 3) do
                expect(approved_and_paid.today_is_valid_renewal_date?).to be_truthy

                expect(subject.docs_uploaded?(approved_and_paid)).to be_falsey
                expect(subject.requirements_excluding_payments_met?(approved_and_paid)).to be_falsey
                expect(subject.payment_requirements_met?(approved_and_paid)).to be_truthy

                expect(subject.requirements_met?({ user: approved_and_paid })).to be_falsey
              end
            end
          end

        end

        context 'membership guidelines NOT agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(false) }

          it 'always false' do
            approved_and_paid = create(:member_with_expiration_date, expiration_date: Date.current + 100)
            expect(subject.requirements_met?(user: approved_and_paid)).to be_falsey
          end
        end
      end

      context 'does not have an approved application: always false' do

        context 'membership guidelines ARE agreed to' do
          before(:each) { allow(UserChecklistManager).to receive(:completed_membership_guidelines_checklist?).and_return(true) }

          ShfApplication.all_states.reject { |s| s == ShfApplication::STATE_ACCEPTED }.each do |app_state|

            context "app is #{app_state}" do

              it "false if membership payment made (and it has not expired)" do
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_user = unapproved_app.user
                start_date, expire_date = User.next_membership_payment_dates(unapproved_user.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_user,
                       start_date: start_date,
                       expire_date: expire_date)

                expect(subject.requirements_met?({ user: unapproved_user })).to be_falsey
              end

              it "false if membership payment made and it HAS expired FIXME" do
                # @fixme - should this be a former member?
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_and_paid = unapproved_app.user

                start_date, expire_date = User.next_membership_payment_dates(unapproved_and_paid.id)
                create(:membership_fee_payment,
                       :successful,
                       user: unapproved_and_paid,
                       start_date: start_date,
                       expire_date: expire_date)

                travel_to(expire_date + 1.day) do
                  expect(subject.requirements_met?({ user: unapproved_and_paid })).to be_falsey
                end
              end

              it "false if membership payment not made" do
                unapproved_app = create(:shf_application, state: app_state)
                unapproved_applicant = unapproved_app.user
                expect(subject.requirements_met?({ user: unapproved_applicant })).to be_falsey
              end
            end
          end
        end
      end
    end


    describe '.requirements_excluding_payments_met?' do

      # Data is based on production data from approx Nov 2, 2021

      # Create <number of weeks> members, 1 per week starting on the given start date. (default start date = 1 January of the given year)
      def create_members_every_week(number_of_weeks = 52, start_date = Date.new(Date.current.year,1,1), company_number: 6759139469)
        next_date = start_date
        number_of_weeks.times do
          # puts "[#{week_num}] next_date: #{next_date} #{next_date.strftime('%A')}"
          m = create(:member, first_day: next_date, company_number: company_number )
          m.uploaded_files.each{|f| f.update(created_at: next_date)}
          m.update(membership_status: User::STATE_CURRENT_MEMBER, membership_number: m.id)
          next_date  +=  1.week
        end

      end

      # See if each member in the given list can renew on the given date and put the result into a list.
      # Return a list of results for all of the given members
      def can_renew_results(members_to_renew, renewal_date = Date.current)
        renewal_results = []
        (members_to_renew).each do |u|
          req_result = RequirementsForRenewal.requirements_excluding_payments_met?(u, renewal_date)
          renewal_results << {
            user_id: u.id,
            result: req_result,
            failure_reason: RequirementsForRenewal.failed_requirements
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
          output =  "User [#{result[:user_id]}] #{User.find(result[:user_id]).membership_status} #{renewable}"
          unless  result[:result]

            output << ':  ' + result[:failure_reason].map{|reason| reason[:string] }.join('; ')
          end
          summary << output + "\n"
        end
        summary
      end


      let(:company) { create(:company) }

      let(:members_to_renew) { (User.current_member + User.in_grace_period).sort_by(&:id) }
      let(:renewal_date) { Date.new(2021, 12, 1) }


      xit 'right number of those that can/not renew' do

        current_member_status = User::STATE_CURRENT_MEMBER

        # the grace period is 1 year
        # The number of days before the last day that someone can renew is 90 days.
        # Be sure to test all of the variations of when someone could have agreed to the membership

        allow(AdminOnly::AppConfiguration.instance).to receive(:membership_expiring_soon_days).and_return(90)
        allow(AdminOnly::AppConfiguration.instance).to receive(:membership_expired_grace_period_duration).and_return(ActiveSupport::Duration.parse('P1Y'))
        allow(UserChecklistManager).to receive(:membership_guidelines_required_date).and_return(Date.new(Date.current.year - 1, 2, 1))

        # puts "membership_expiring_soon_days: #{AdminOnly::AppConfiguration.instance.membership_expiring_soon_days}"
        # puts "membership_expired_grace_period_duration: #{AdminOnly::AppConfiguration.instance.membership_expired_grace_period_duration.parts}"
        # puts "membership_guidelines_required_date: #{UserChecklistManager.membership_guidelines_required_date}"

        june1_2021 = Date.new(2021, 6, 1)
        june2_2021 = Date.new(2021, 6, 2)
        june3_2021 = Date.new(2021, 6, 3)
        june4_2021 = Date.new(2021, 6, 4)

        travel_to(june1_2021 - 1.year + 1.day) do
           create(:member, last_day: june1_2021, email: 'in_grace_pd_can_renew@example.com',
                                       company_number: company.company_number, membership_status: current_member_status)
        end
        last_day_2021_06_01 = User.find_by(email: 'in_grace_pd_can_renew@example.com')
        upload = create(:uploaded_file, :txt, user: last_day_2021_06_01)
        upload.update(created_at: june1_2021)
        upload = create(:uploaded_file, :txt, user: last_day_2021_06_01)
        upload.update(created_at: june1_2021 + 1.day)
        guidelines_in_grace_pd = UserChecklistManager.find_or_create_after_latest_membership_last_day(last_day_2021_06_01)
        guidelines_in_grace_pd&.set_complete_including_children( june1_2021 + 1.day)

        travel_to(june2_2021 - 1.year + 1.day) do
          create(:member, last_day: june2_2021, email: 'in_grace_pd_missing_uploads@example.com',
                  company_number: company.company_number, membership_status: current_member_status )
        end
        last_day_2021_06_02 = User.find_by(email: 'in_grace_pd_missing_uploads@example.com')
        upload = create(:uploaded_file, :txt, user: last_day_2021_06_02)
        upload.update(created_at: june2_2021)
        guidelines_in_grace_pd = UserChecklistManager.find_or_create_after_latest_membership_last_day(last_day_2021_06_02)
        guidelines_in_grace_pd&.set_complete_including_children( june2_2021 + 1.day)


        travel_to(june3_2021 - 1.year + 1.day) do
          create(:member, last_day: june3_2021, email: 'in_grace_pd_missing_guidelines@example.com',
                                     company_number: company.company_number, membership_status: current_member_status )
        end
        last_day_2021_06_03 = User.find_by(email:'in_grace_pd_missing_guidelines@example.com')
        upload = create(:uploaded_file, :txt, user: last_day_2021_06_03)
        upload.update(created_at: june3_2021)
        upload = create(:uploaded_file, :txt, user: last_day_2021_06_03)
        upload.update(created_at: (june3_2021 + 1.day))

        travel_to(june4_2021 - 1.year + 1.day) do
          create(:member, last_day: june4_2021, email:'in_grace_pd_missing_uploads_and_guidelines@example.com',
                 company_number: company.company_number, membership_status: current_member_status )
        end
        last_day_2021_06_04 = User.find_by(email: 'in_grace_pd_missing_uploads_and_guidelines@example.com')
        upload = create(:uploaded_file, :txt, user: last_day_2021_06_04)
        upload.update(created_at: june4_2021)


        # Creeate members that agreed to the Membership guidelines :
        #  - agreed before renewals were implemented, and perhaps before the current membership started
        jan2 =  Date.new(Date.current.year,1,2)
        agreed_before_renewals_implemented = create(:member, first_day: jan2, company_number: company.company_number )
        agreed_before_renewals_implemented.uploaded_files.each{|f| f.update(created_at: jan2)}
        agreed_before_renewals_implemented.update(membership_status: User::STATE_CURRENT_MEMBER, membership_number: agreed_before_renewals_implemented.id)
        UserChecklistManager.most_recent_membership_guidelines_list_for(agreed_before_renewals_implemented)&.set_complete_including_children(UserChecklistManager.membership_guidelines_required_date - 1.day)

        # Paid for 2 memberships at once ( = paid for 1 in advance)
        last_year = Date.current.year - 1
        jan1_last_year = Date.new(last_year, 1, 1)
        jan1 = Date.new(Date.current.year, 1, 1)
        dec31_next_year = jan1 + 1.year - 1.day

        travel_to jan1_last_year do
          paid_for_2 =  create(:member, first_day: jan1_last_year, company_number: company.company_number,
                               email: 'paid-for-2@example.com')
          paid_for_2.uploaded_files.each{|f| f.update(created_at: jan1_last_year)}
          paid_for_2.update(membership_status: User::STATE_CURRENT_MEMBER, membership_number: paid_for_2.id)
          # pays for 2 years:
          paid_for_2.payments.member_fee.first.update(expire_date:dec31_next_year )
        end

        paid_for_2 = User.find_by(email:  'paid-for-2@example.com')
        travel_to jan1 do
          create(:membership, user: paid_for_2, first_day: jan1, last_day: (jan1 + 1.year - 1.day))
        end

        travel_to (jan1 + 11.months) do
          AdminOnly::UserChecklistFactory.create_member_guidelines_checklist_for(paid_for_2)
          UserChecklistManager.most_recent_membership_guidelines_list_for(paid_for_2)&.set_complete_including_children(Date.current)
          create(:uploaded_file, :txt, user: paid_for_2)
        end


        # The first 5 of these will be able to renew. The last 2 will not because it is too early for them to renew.
        create_members_every_week(7, company_number: company.company_number) # creates 52 members starting 1 jan of this year


        travel_to renewal_date do
          User.all.each do |user|
            MembershipStatusUpdater.instance.update_membership_status(user, send_email: false)
          end
        end

        # puts "#{User.count} total Users"
        # puts "#{User.in_grace_period.count} in_grace_period"
        # puts "#{User.current_member.count} current_member"
        #
        # puts "======================"

        members_to_renew = (User.current_member + User.in_grace_period).sort_by(&:id)
        # puts "members not current_member or in_grace_period:"
        # (User.all - User.current_member - User.in_grace_period).each do |u|
        #   pp u
        #   # u.memberships.each{|m| pp m}
        # end
        # puts "======================"

        expect(members_to_renew.count).to eq 13

        renew_results = can_renew_results(members_to_renew, renewal_date)
        # puts renewal_results_summary(renew_results)

        expect(renew_results.select{|results| results[:result]}.count).to eq(8) # can renew
        expect(renew_results.reject{|results| results[:result]}.count).to eq(5) # these are too early to renew
      end

    end
  end
end
