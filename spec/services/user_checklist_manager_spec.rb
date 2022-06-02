require 'rails_helper'

require 'shared_context/users'

RSpec.describe UserChecklistManager do

  include ActiveSupport::Testing::TimeHelpers

  include_context 'create users'

  let(:june_6) { Time.zone.local(2020, 6, 6) }
  let(:june_5) { Time.zone.local(2020, 6, 5) }

  # @todo get this from AppConfiguration later / stub (the membership guidelines list type, etc.)
  let(:membership_guidelines_type_name) { AdminOnly::MasterChecklistType::MEMBER_GUIDELINES_LIST_TYPE }
  let(:guideline_list_type) { create(:master_checklist_type, name: membership_guidelines_type_name) }
  let(:guideline_master) { create(:master_checklist, master_checklist_type: guideline_list_type) }

  let(:u) { build(:user) }
  let(:yesterday) { Date.current - 1 }
  let(:completion_date_20200102) { Date.new(2020, 1, 2) }

  CURRENT_MEMBER_STATUS = User::STATE_CURRENT_MEMBER
  IN_GRACE_PERIOD_STATUS = User::STATE_IN_GRACE_PERIOD
  FORMER_MEMBER_STATUS = User::STATE_FORMER_MEMBER
  NOT_A_MEMBER_STATUS = User::STATE_NOT_A_MEMBER

  describe '.can_user_do_membership_guidelines?' do

    it 'false if user is nil' do
      expect(described_class.can_user_do_membership_guidelines?(nil)).to be_falsey
    end

    it 'false if user has not submitted a SHF Application' do
      user_no_application = build(:user)
      expect(described_class.can_user_do_membership_guidelines?(user_no_application)).to be_falsey
    end

    it 'true if user has submitted a SHF Application' do
      applicant = build(:user)
      applicant.shf_application = build(:shf_application)
      expect(described_class.can_user_do_membership_guidelines?(applicant)).to be_truthy
    end
  end


  describe '.completed_membership_guidelines_checklist?' do

    context 'current member' do
      let(:current_member) { build(:user, membership_status: CURRENT_MEMBER_STATUS) }

      it 'calls current_member_completed_membership_guidelines_checklist? with the user' do
        expect(described_class).to receive(:current_member_completed_membership_guidelines_checklist?)
                                     .with(current_member)
                                     .and_return(true)
        expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_truthy
      end
    end

    [IN_GRACE_PERIOD_STATUS, FORMER_MEMBER_STATUS].each do |status|
      context "#{status}" do
        let(:grace_pd_member) { build(:user, membership_status: status) }

        it 'true if most recent guidelines list is all completed after the membership ended' do
          expect(described_class).to receive(:find_after_latest_membership_end)
                                       .with(grace_pd_member)
                                       .and_return(create(:user_checklist, :completed, user: grace_pd_member))
          expect(described_class.completed_membership_guidelines_checklist?(grace_pd_member)).to be_truthy
        end

        it 'false if most recent guidelines list are not all completed' do
          expect(described_class).to receive(:find_after_latest_membership_end)
                                       .with(grace_pd_member)
                                       .and_return(create(:user_checklist, user: grace_pd_member))
          expect(described_class.completed_membership_guidelines_checklist?(grace_pd_member)).to be_falsey
        end

        it 'false if guidelines were completed on or before the membership ended' do
          membership_last_day = Date.current - 1.month

          # mocking/using doubles would be quite a pain, so we do the slow thing and use the db
          member_ended_1_month_ago = create(:member, last_day: membership_last_day,
                                            membership_status: status)

          # update values so it looks like this was created and completed on the last day of the membership
          UserChecklist.for_user(member_ended_1_month_ago).each do |checklist|
            checklist.update(date_completed: membership_last_day,
                             created_at: membership_last_day)
          end

          expect(described_class).to receive(:find_after_latest_membership_end)
                                       .with(member_ended_1_month_ago)
                                       .and_call_original
          expect(described_class.completed_membership_guidelines_checklist?(member_ended_1_month_ago)).to be_falsey
        end
      end
    end

    context 'not a member' do
      let(:not_a_member) { build(:user, membership_status: NOT_A_MEMBER_STATUS) }

      it 'true if guidelines list is all completed' do
        expect(described_class).to receive(:find_or_create_membership_guidelines_list)
                                     .with(not_a_member)
                                     .and_return(create(:user_checklist, :completed, user: not_a_member))
        expect(described_class.completed_membership_guidelines_checklist?(not_a_member)).to be_truthy
      end

      it 'false if guidelines list is not all completed' do
        expect(described_class).to receive(:find_or_create_membership_guidelines_list)
                                     .with(not_a_member)
                                     .and_return(create(:user_checklist, user: not_a_member))
        expect(described_class.completed_membership_guidelines_checklist?(not_a_member)).to be_falsey
      end
    end

    context 'all other membership statuses' do
      (User.membership_statuses + ['some other status'] - [CURRENT_MEMBER_STATUS, IN_GRACE_PERIOD_STATUS,
                                   FORMER_MEMBER_STATUS, NOT_A_MEMBER_STATUS]).each do |status|
        it "#{status} is false" do
          u = build(:user, membership_status: status)
          expect(described_class.completed_membership_guidelines_checklist?(u)).to be_falsey
        end
      end
    end
  end


  describe '.completed_membership_guidelines_checklist_for_renewal?' do

    context 'current member' do
      it 'calls current_member_completed_membership_guidelines_checklist_for_renewal?' do
        u = build(:user, membership_status: CURRENT_MEMBER_STATUS)
        expect(described_class).to receive(:current_member_completed_membership_guidelines_checklist_for_renewal?)
                                     .with(u)
        described_class.completed_membership_guidelines_checklist_for_renewal?(u)
      end
    end

    context 'in grace period' do
      it 'calls in_grace_period_completed_membership_guidelines_checklist_for_renewal?' do
        u = build(:user, membership_status: IN_GRACE_PERIOD_STATUS)
        expect(described_class).to receive(:in_grace_period_completed_membership_guidelines_checklist_for_renewal?)
                                     .with(u)
        described_class.completed_membership_guidelines_checklist_for_renewal?(u)
      end
    end

    context 'all other membership statuses' do
      (User.membership_statuses + ['some_other_status'] - [CURRENT_MEMBER_STATUS, IN_GRACE_PERIOD_STATUS]).each do |status|
        it "#{status} is false" do
          expect(described_class.completed_membership_guidelines_checklist_for_renewal?(build(:user, membership_status: status))).to be_falsey
        end
      end
    end
  end


  describe '.current_member_completed_membership_guidelines_checklist?' do
    # from production data: summary of info for User 655
    #      - has 2 memberships
    #      - paid for one membership in advance
    #      - completed the Ethical Guidelines checklist on 20 Oct 2021
    #
    #                      :user_id => 655,
    #                        :email => "nina.swenning@telia.com",
    #                       :status => "current_member",
    #              :num_memberships => 2,
    #                 :checklist_id => 15721,
    #     :date_checklist_completed => Wed, 20 Oct 2021 11:14:28 UTC +00:00,
    #                  :memberships => [
    #         [0] {
    #             :membership_id => 49,
    #                 :first_day => Wed, 25 Nov 2020,
    #                  :last_day => Wed, 24 Nov 2021,
    #                :created_at => Sun, 19 Sep 2021 23:59:35 UTC +00:00
    #         },
    #         [1] {
    #             :membership_id => 425,
    #                 :first_day => Thu, 25 Nov 2021,
    #                  :last_day => Thu, 24 Nov 2022,
    #                :created_at => Wed, 20 Oct 2021 11:21:50 UTC +00:00
    #         }
    #     ]
    # }
    #
    context 'current member' do
      let(:current_member) { build(:user, membership_status: CURRENT_MEMBER_STATUS) }
      let(:cutoff_date) { UserChecklistManager::MEMBERSHIP_GUIDELINES_AGREE_ANYTIME_CUTOFF_DATE }
      let(:agreed_before_cutoff_date_1) { create(:user_checklist, date_completed: cutoff_date - 1.day, user: current_member) }
      let(:agreed_before_cutoff_date_2) { create(:user_checklist, date_completed: cutoff_date - 1.day, user: current_member) }
      let(:agreed_on_cutoff_date) { create(:user_checklist, date_completed: cutoff_date, user: current_member) }
      let(:agreed_after_cutoff_date_1) { create(:user_checklist, date_completed: cutoff_date + 1.day, user: current_member) }
      let(:agreed_after_cutoff_date_2) { create(:user_checklist, date_completed: cutoff_date + 1.day, user: current_member) }

      context 'no uncompleted guidelines' do
        before(:each) do
          allow(UserChecklist).to receive(:not_completed_by_user)
                                    .with(current_member)
                                    .and_return([])
        end

        it 'false if no completed guidelines' do
          allow(UserChecklist).to receive(:completed_by_user)
                                    .with(current_member)
                                    .and_return([])
          expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_falsey
        end

        it 'true if agreed to all guidelines before full implementation cutoff date' do
          allow(UserChecklist).to receive(:completed_by_user)
                                    .with(current_member)
                                    .and_return([agreed_before_cutoff_date_1, agreed_before_cutoff_date_2])

          expect(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                     .with(current_member)
                                     .at_least(1).time
                                     .and_return(agreed_before_cutoff_date_2)

          expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_truthy
        end

        context 'not all guidelines agreed to before full implementation cutoff date' do
          before(:each) do
            allow(UserChecklist).to receive(:completed_by_user)
                                      .with(current_member)
                                      .and_return([agreed_before_cutoff_date_1,
                                                   agreed_on_cutoff_date,
                                                   agreed_after_cutoff_date_1])
          end


          context 'have not paid for memberships in advance' do
            before(:each) do
              allow(Memberships::MembershipsManager).to receive(:user_paid_in_advance?)
                                             .with(current_member)
                                             .and_return(false)
              expect(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                         .with(current_member)
                                         .and_return(agreed_after_cutoff_date_1)
            end


            it 'true if most recent agreed to date was within the window for the current membership' do
              current_membership = create(:membership, owner: current_member,
                                          first_day: agreed_after_cutoff_date_1.date_completed,
                                          last_day: Date.current + 1.day)

              allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                        .with(current_member)
                                        .and_return(agreed_after_cutoff_date_1)

              allow(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                             .with(current_member)
                                             .and_return(current_membership)

              expect(Memberships::MembershipsManager).to receive(:valid_membership_guidelines_agreement_date?)
                                             .with(current_membership, anything)
                                             .and_return(true)
              expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_truthy
            end

            it 'false most recent agreed to date is not within window for agreeing ' do
              current_membership = create(:membership, owner: current_member,
                                          first_day: (agreed_after_cutoff_date_1.date_completed - 1.day),
                                          last_day: Date.current + 1.day)
              allow(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                             .with(current_member)
                                             .and_return(current_membership)
              expect(Memberships::MembershipsManager).to receive(:valid_membership_guidelines_agreement_date?)
                                              .with(current_membership, anything)
                                              .and_return(false)

              expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_falsey
            end
          end

          context 'have paid for memberships in advance' do
            before(:each) do
              allow(Memberships::MembershipsManager).to receive(:user_paid_in_advance?)
                                             .with(current_member)
                                             .and_return(true)
              expect(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                         .with(current_member)
                                         .and_return(agreed_after_cutoff_date_1)
            end

            let(:payment_before_agreed) { build(:membership_fee_payment, user: current_member)  }

            it 'true if agreed to guidelines on or before the date paid' do
              payment_before_agreed.created_at = agreed_after_cutoff_date_1.date_completed
              allow(current_member).to receive(:most_recent_payment)
                                         .and_return(payment_before_agreed)

              expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_truthy
            end

            it 'false otherwise' do
              payment_before_agreed.created_at = agreed_after_cutoff_date_1.date_completed + 1.day

              allow(current_member).to receive(:most_recent_payment)
                                         .and_return(payment_before_agreed)

              expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_truthy
            end
          end
        end
      end

      it 'false if there are uncompleted top level guidelines' do
        allow(UserChecklist).to receive(:not_completed_by_user)
                                  .with(current_member)
                                  .and_return([create(:user_checklist, user: current_member)])

        expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_falsey
      end

      # it 'only has 1 membership' do
      #   # They may have agreed to them before we actually implemented the Membership model
      #   # so it's ok for them to have agreed at any time. (Not everything was implemented,
      #   # so we don't require them to have agreed on or before their membership started.)
      #   pending
      #
      # end
      #
      # context 'has more than 1 membership' do
      #
      #   context 'agreed to guidelines before 2021-11-01' do
      #     pending
      #   end
      #
      #   context 'agreed to guidelines on or after 2021-11-01' do
      #     pending
      #   end
      # end
      #
      # it 'true if the most recent guidelines list is all completed' do
      #   expect(described_class).to receive(:most_recent_membership_guidelines_list_for)
      #                                .with(current_member)
      #                                .and_return(create(:user_checklist, :completed, user: current_member))
      #   expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_truthy
      # end
      #
      # it 'false if the most recent guidelines list is not all completed' do
      #   expect(described_class).to receive(:most_recent_membership_guidelines_list_for)
      #                                .with(current_member)
      #                                .and_return(build(:user_checklist, user: current_member))
      #   expect(described_class.completed_membership_guidelines_checklist?(current_member)).to be_falsey
      # end
    end

  end


  describe '.current_member_completed_membership_guidelines_checklist_for_renewal?' do

    context 'membership status is not a current member' do
      (User.membership_statuses + ['some_other_status'] - [CURRENT_MEMBER_STATUS]).each do |status|
        it "false for #{status}" do
          u = build(:user, membership_status: status)
          expect(described_class.current_member_completed_membership_guidelines_checklist_for_renewal?(u)).to be_falsey
        end
      end
    end

    context 'is a current member' do
      let(:current_member) { build(:user, membership_status: CURRENT_MEMBER_STATUS) }
      let(:yesterday) { Date.current - 1.day }
      before(:each) { allow(described_class).to receive(:membership_guidelines_required_date).and_return(yesterday) }

      it 'gets the most recent completed guideline date' do
        faux_membership = build(:membership, owner: current_member, last_day: Date.new(2021,1,1))
        allow(current_member).to receive(:current_membership).and_return(faux_membership)
        allow(described_class).to receive(:checklist_complete_after?)

        most_recent_completed_guideline = build(:user_checklist, :completed, created_at: Date.current)
        expect(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                   .with(current_member)
                                   .and_return(most_recent_completed_guideline)
        described_class.current_member_completed_membership_guidelines_checklist_for_renewal?(current_member)
      end

      context 'the first day of membership is before when guidelines were required' do
        let(:membership_starts_b4_guidelines_reqd) { build(:membership, owner: current_member, first_day:(yesterday - 1.week)) }
        before(:each) { allow(current_member).to receive(:current_membership).and_return(membership_starts_b4_guidelines_reqd) }

        it 'true if the most recent completed guidelines were before the guidelines were fully implemented' do
          most_recent_completed_guideline = build(:user_checklist,  date_completed: (yesterday - 1.day))
          allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                     .with(current_member)
                                     .and_return(most_recent_completed_guideline)
          expect(described_class).not_to receive(:checklist_complete_after?)
          expect(described_class.current_member_completed_membership_guidelines_checklist_for_renewal?(current_member)).to be_truthy
        end

        context 'most recently completed guidelines were after the fully implemented date' do
          let(:most_recent_completed_guideline) { build(:user_checklist, date_completed: (yesterday + 1.day)) }

          it 'calls checklist_completed_after? with the 2nd day of the current membership' do
            allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                       .with(current_member)
                                       .and_return(most_recent_completed_guideline)
            expect(described_class).to receive(:checklist_complete_after?)
                                       .with(current_member, (yesterday - 1.week + 1.day))
            described_class.current_member_completed_membership_guidelines_checklist_for_renewal?(current_member)
          end
        end
      end

      context 'the first day of membership is when the guidelines were required' do
        let(:membership_starts_on_guidelines_reqd) { build(:membership, owner: current_member, first_day: yesterday) }
        let(:most_recent_completed_guideline) { build(:user_checklist, date_completed: (yesterday + 1.day)) }
        before(:each) { allow(current_member).to receive(:current_membership).and_return(membership_starts_on_guidelines_reqd) }

        it 'calls checklist_completed_after? with the 2nd day of the current membership' do
          allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                    .with(current_member)
                                    .and_return(most_recent_completed_guideline)
          expect(described_class).to receive(:checklist_complete_after?)
                                       .with(current_member, (yesterday + 1.day))
          described_class.current_member_completed_membership_guidelines_checklist_for_renewal?(current_member)
        end
      end


      context 'the first day of membership is after when guidelines were required' do
        let(:membership_starts_after_guidelines_reqd) { build(:membership, owner: current_member, first_day:(yesterday + 1.day)) }
        let(:most_recent_completed_guideline) { build(:user_checklist, date_completed: (yesterday + 1.day)) }
        before(:each) { allow(current_member).to receive(:current_membership).and_return(membership_starts_after_guidelines_reqd) }

        it 'calls checklist_completed_after? with the 2nd day of the current membership' do
          allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                    .with(current_member)
                                    .and_return(most_recent_completed_guideline)
          expect(described_class).to receive(:checklist_complete_after?)
                                       .with(current_member, (yesterday + 1.day + 1.day))
          described_class.current_member_completed_membership_guidelines_checklist_for_renewal?(current_member)
        end
      end
    end
  end

  describe '.in_grace_period_completed_membership_guidelines_checklist_for_renewal??' do

    context 'membership status is not in the grace period' do
      (User.membership_statuses + ['some_other_status'] - [IN_GRACE_PERIOD_STATUS]).each do |status|
        it "false for #{status}" do
          u = build(:user, membership_status: status)
          expect(described_class.in_grace_period_completed_membership_guidelines_checklist_for_renewal?(u)).to be_falsey
        end
      end
    end

    context 'is in grace period' do
      let(:user_in_grace_pd) { build(:user, membership_status: IN_GRACE_PERIOD_STATUS) }

      it 'calls checklist_completed_after? with the 2nd day of the most recent membership' do
        faux_membership = build(:membership, owner: user_in_grace_pd, last_day: Date.new(2021,1,1))
        allow(user_in_grace_pd).to receive(:in_grace_period?).and_return(true)
        allow(user_in_grace_pd).to receive(:most_recent_membership).and_return(faux_membership)

        expect(described_class).to receive(:checklist_complete_after?)
                                     .with(user_in_grace_pd, Date.new(2021,1,2))
        described_class.in_grace_period_completed_membership_guidelines_checklist_for_renewal?(user_in_grace_pd)
      end
    end
  end

  describe '.checklist_complete_after?' do

    it 'gets the top level UserChecklists created after the given date' do
      u = build(:user)
      given_date = Date.new(2021,1,1)
      expect(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                 .with(u, given_date)
                                 .and_return([])
      described_class.checklist_complete_after?(u, given_date)
    end

    it 'false if there are no UserChecklists created after the given date' do
      allow(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                .with(anything, anything)
                                 .and_return([])
      expect(described_class.checklist_complete_after?(build(:user),  Date.new(2021,1,1))).to be_falsey
    end

    context 'there are UserChecklists created after the given date' do
      it 'true if the first UserChecklist is completed' do
        completed_guidelines_top = build(:user_checklist, :completed, created_at: Date.new(2021,6,6))
        allow(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                  .with(anything, anything)
                                  .and_return([completed_guidelines_top])
        expect(described_class.checklist_complete_after?(build(:user), Date.new(2021,1,1))).to be_truthy
      end

      it 'false if the first UserChecklist is not completed' do
        not_completed_guidelines_top = build(:user_checklist, created_at: Date.new(2021,6,6))
        allow(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                  .with(anything, anything)
                                  .and_return([not_completed_guidelines_top])
        expect(described_class.checklist_complete_after?(build(:user), Date.new(2021,1,1))).to be_falsey
      end
    end
  end


  describe '.find_or_create_guidelines_method' do

    shared_examples "is :find_or_create_membership_guidelines_list for status" do |status, renewal|
      it "#{status}" do
        expect(described_class.find_or_create_guidelines_method(status, is_renewal: renewal))
          .to eq(:find_or_create_membership_guidelines_list)
      end
    end

    shared_examples "is :find_or_create_after_latest_membership_last_day for status" do |status, renewal|
      it "#{status}" do
        expect(described_class.find_or_create_guidelines_method(status, is_renewal: renewal))
          .to eq(:find_or_create_after_latest_membership_last_day)
      end
    end
    # ------------------------------------------

    context 'is a renewal' do
      is_a_renewal = true

      it 'current_member returns :find_or_create_on_or_after_current_membership_start' do
        expect(described_class.find_or_create_guidelines_method(CURRENT_MEMBER_STATUS, is_renewal: is_a_renewal))
          .to eq(:find_or_create_on_or_after_current_membership_start)
      end

      it 'in_grace_period returns :find_or_create_after_latest_membership_last_day' do
        expect(described_class.find_or_create_guidelines_method(IN_GRACE_PERIOD_STATUS, is_renewal: is_a_renewal))
          .to eq(:find_or_create_after_latest_membership_last_day)
      end

      it_behaves_like "is :find_or_create_membership_guidelines_list for status", User::STATE_NOT_A_MEMBER, is_a_renewal
      it_behaves_like "is :find_or_create_after_latest_membership_last_day for status", User::STATE_FORMER_MEMBER, is_a_renewal

      # Any other statuses
      (User.membership_statuses + ['any other status'] - [CURRENT_MEMBER_STATUS, IN_GRACE_PERIOD_STATUS,
                                   User::STATE_NOT_A_MEMBER, User::STATE_FORMER_MEMBER]).each do |status|
        it_behaves_like "is :find_or_create_membership_guidelines_list for status", status, is_a_renewal
      end
    end

    context 'is not a renewal' do
      is_a_renewal = false

      it_behaves_like "is :find_or_create_membership_guidelines_list for status", User::STATE_CURRENT_MEMBER, is_a_renewal
      it_behaves_like "is :find_or_create_membership_guidelines_list for status", User::STATE_NOT_A_MEMBER, is_a_renewal
      it_behaves_like "is :find_or_create_after_latest_membership_last_day for status", User::STATE_IN_GRACE_PERIOD, is_a_renewal
      it_behaves_like "is :find_or_create_after_latest_membership_last_day for status", User::STATE_FORMER_MEMBER, is_a_renewal

      # Any other statuses
      (User.membership_statuses + ['any other status'] - [CURRENT_MEMBER_STATUS, IN_GRACE_PERIOD_STATUS,
                                                          User::STATE_NOT_A_MEMBER, User::STATE_FORMER_MEMBER]).each do |status|
        it_behaves_like "is :find_or_create_membership_guidelines_list for status", status, is_a_renewal
      end
    end
  end


  describe '.find_or_create_on_or_after_latest_membership_start' do
    let(:latest_membership) { build(:membership, owner: user, first_day: yesterday) }

    let(:most_recent_checklist) { build(:user_checklist, :completed, user: user,
                                        date_completed: completion_date_20200102) }

    it 'gets the first day of the most recent membership for the user' do
      allow(described_class).to receive(:create_for_user_if_needed)
      expect(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                      .with(u)
                                      .and_return(latest_membership)
      expect(latest_membership).to receive(:first_day)
                                     .and_return(yesterday)

      described_class.find_or_create_on_or_after_latest_membership_start(u)
    end

    it 'calls find_or_create_on_or_after with the user and first_day of the most recent membership' do
      allow(described_class).to receive(:create_for_user_if_needed)
      allow(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                      .with(u)
                                      .and_return(latest_membership)
      allow(latest_membership).to receive(:first_day)
                                     .and_return(yesterday)

      expect(described_class).to receive(:find_or_create_on_or_after)
                                   .with(u, yesterday)
      described_class.find_or_create_on_or_after_latest_membership_start(u)
    end
  end


  describe '.find_or_create_on_or_after_current_membership_start' do

    context 'the user has a current membership' do
      let(:current_membership) { build(:membership, owner: user, first_day: yesterday) }
      let(:most_recent_checklist) { build(:user_checklist, :completed, user: user,
                                          date_completed: completion_date_20200102) }
      before(:each) do
        allow(Memberships::MembershipsManager).to receive(:current_membership)
                                       .with(u)
                                       .and_return(current_membership)
      end

      it 'gets the first day of the current membership for the user' do
        allow(described_class).to receive(:create_for_user_if_needed)
        expect(Memberships::MembershipsManager).to receive(:current_membership)
                                        .with(u)
                                        .and_return(current_membership)
        expect(current_membership).to receive(:first_day)
                                       .and_return(yesterday)

        described_class.find_or_create_on_or_after_current_membership_start(u)
      end

      it 'calls find_or_create_on_or_after with the user and first_day of the current membership' do
        allow(described_class).to receive(:create_for_user_if_needed)
        allow(Memberships::MembershipsManager).to receive(:current_membership)
                                       .with(u)
                                       .and_return(current_membership)
        allow(current_membership).to receive(:first_day)
                                      .and_return(yesterday)

        expect(described_class).to receive(:find_or_create_on_or_after)
                                     .with(u, yesterday)
        described_class.find_or_create_on_or_after_current_membership_start(u)
      end

    end
  end


  describe '.find_or_create_after_latest_membership_last_day' do
    let(:latest_membership) { build(:membership, owner: user, last_day: yesterday) }

    it 'gets the last day of the most recent membership for the user' do
      allow(described_class).to receive(:create_for_user_if_needed)
      expect(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                      .with(u)
                                      .and_return(latest_membership)
      expect(latest_membership).to receive(:last_day)
                                     .and_return(tomorrow)
      described_class.find_or_create_after_latest_membership_last_day(u)
    end

    it 'calls find_or_create_on_or_after with the user and the day after the last day of the most recent membership' do
      allow(described_class).to receive(:create_for_user_if_needed)
      allow(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                     .with(u)
                                     .and_return(latest_membership)
      allow(latest_membership).to receive(:last_day)
                                     .and_return(tomorrow)

      expect(described_class).to receive(:find_or_create_on_or_after)
                                   .with(u, tomorrow + 1.day)
      described_class.find_or_create_after_latest_membership_last_day(u)
    end
  end

  describe '.find_or_create_on_or_after' do
    let(:u) { build(:user) }
    let(:given_date) { Date.current }
    let(:latest_membership) { build(:membership, owner: u, last_day: yesterday) }
    let(:most_recent_checklist) { build(:user_checklist, :completed, user: user,
                                        date_completed: (yesterday)) }

    it 'creates the guidelines if no date is given' do
      expect(described_class).to receive(:create_for_user_if_needed).with(u)
      described_class.find_or_create_on_or_after(u)
    end

    it 'gets the uncompleted top level guideline created on or after the given date' do
      allow(described_class).to receive(:create_for_user_if_needed)

      top_level_checklists = double("UserChecklist::ActiveRecord_Relation")
      allow(top_level_checklists).to receive(:uncompleted).and_return([])
      allow(described_class).to receive(:create_for_user_if_needed)

      expect(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                 .with(u, latest_membership.last_day + 1.day)
                                 .and_return(top_level_checklists)
      described_class.find_or_create_on_or_after(u, given_date)
    end

    context 'no incomplete guideline checklists created on or after the given date' do
      before(:each) do
        top_level_checklists = double("UserChecklist::ActiveRecord_Relation")
        allow(top_level_checklists).to receive(:uncompleted).and_return([])
      end

      it 'calls create for user if needed with the user and a nil guideline' do
        expect(described_class).to receive(:create_for_user_if_needed).with(u, guideline: nil)
        described_class.find_or_create_on_or_after(u, given_date)
      end
    end

    context 'there are incomplete checklists created on or after the given date' do
      before(:each) do
        top_level_checklists = double("UserChecklist::ActiveRecord_Relation")
        allow(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                  .and_return(top_level_checklists)
        allow(top_level_checklists).to receive(:uncompleted).and_return([most_recent_checklist])
      end

      it 'calls create for user if needed with the user and the latest found guideline checklist' do
        expect(described_class).to receive(:create_for_user_if_needed).with(u, guideline: most_recent_checklist)
        described_class.find_or_create_on_or_after(u, given_date)
      end
    end

    it 'returns the found guideline or creates one' do
      expect(described_class).to receive(:create_for_user_if_needed)
                                   .with(u, anything)

      described_class.find_or_create_on_or_after(u, given_date)
    end
  end


  describe '.find_after_latest_membership_end' do

    it 'nil if there is no most recent membership for a user' do
      expect(described_class.find_after_latest_membership_end(build(:user))).to be_nil
    end

    it 'calls UserChecklist.most_recently_created_top_level_guidelines for 1 day after the last day of the most recent membership\'s last day' do

      faux_membership = build(:membership, last_day: yesterday)
      expect(Memberships::MembershipsManager).to receive(:most_recent_membership).with(user)
                                                                    .and_return(faux_membership)
      expect(UserChecklist).to receive(:most_recently_created_top_level_guidelines)
                                 .with(user, Date.current)
                                 .and_return([])
      described_class.find_after_latest_membership_end(user)
    end
  end


  describe '.first_incomplete_membership_guideline_section_for' do

    it 'nil if all are completed' do
      user_all_completed = build(:user, first_name: 'AllCompleted')
      user_checklist = create(:user_checklist, user: user_all_completed,
                              master_checklist: guideline_master,
                              num_completed_children: 2)
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                  .with(user_all_completed)
                                                  .and_return(user_checklist)
      expect(described_class.first_incomplete_membership_guideline_section_for(user_all_completed)).to be_nil
    end

    it 'first incomplete guideline (based on the list position) of the membership guidelines' do
      user_some_completed = build(:user, first_name: 'SomeCompleted')
      user_checklist = create(:user_checklist, user: user_some_completed,
                              master_checklist: guideline_master,
                              num_children: 3,
                              num_completed_children: 2)
      allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                  .with(user_some_completed)
                                                  .and_return(user_checklist)
      allow(described_class).to receive(:most_recent_membership_guidelines_list_for)
                                  .with(user_some_completed)
                                  .and_return(user_checklist)
      result = described_class.first_incomplete_membership_guideline_section_for(user_some_completed)
      expect(result.completed?).to be_falsey
    end
  end

  describe 'find_or_create_membership_guidelines_list' do
    it 'gets the most reccent membership guidelines list and creates for the user if needed' do
      u = build(:user)
      allow(described_class).to receive(:most_recent_membership_guidelines_list_for)
                                  .and_return(nil)

      expect(described_class).to receive(:create_for_user_if_needed)
                                   .with(u, guideline: nil)
      described_class.find_or_create_membership_guidelines_list(u)
    end
  end


  describe 'create_for_user_if_needed' do

    it 'default guideline is nil' do
      expect(described_class).to receive(:create_for_user).with(u)
      described_class.create_for_user_if_needed(u)
    end

    it 'creates a new set of checklists for the user if the guideline is nil' do
      expect(described_class).to receive(:create_for_user).with(u)
      described_class.create_for_user_if_needed(u, guideline: nil)
    end

    it 'returns the given guideline if guideline is not nil' do
      expect(described_class).not_to receive(:create_for_user)
      described_class.create_for_user_if_needed(u, guideline: 'blorf')
    end
  end

  describe 'create_for_user' do
    it 'UserChecklistFactory creates a membership guidelines checklist for the user' do
      u = build(:user)
      expect(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                   .with(u)
      described_class.create_for_user(u)
    end
  end

  describe '.most_recent_membership_guidelines_list_for' do

    it 'returns nil if there are no lists for the user' do
      expect(described_class.most_recent_membership_guidelines_list_for(create(:user))).to be_nil
    end

    it 'returns the most recently created user checklist' do
      user = create(:user, first_name: 'User', last_name: 'With-Checklists')

      # make 2 and expect the most recently created one to be returned
      travel_to(Time.zone.now - 2.days) do
        create(:user_checklist, :completed, user: user, name: 'older list')
      end

      create(:user_checklist, :completed, user: user, name: 'more recent list')

      allow(UserChecklist).to receive(:membership_guidelines_for_user).and_return(user.checklists)

      expect(described_class.most_recent_membership_guidelines_list_for(user)).to eq UserChecklist.find_by(name: 'more recent list')
    end

  end

  describe '.completed_guidelines_for' do

    it 'empty list if  there is no list for the user' do
      user_no_checklist = build(:user)
      expect(described_class.completed_guidelines_for(user_no_checklist)).to be_empty
    end

    context 'no guidelines completed' do
      it 'empty list' do
        num_completed = 0
        user_none_completed = build(:user)
        user_checklist = create(:user_checklist, user: user_none_completed,
                                master_checklist: guideline_master,
                                num_children: 2,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_none_completed)
                                                    .and_return(user_checklist)

        expect(described_class.completed_guidelines_for(user_none_completed)).to be_empty
      end
    end

    context 'some guidelines completed' do
      it 'list with only the completed guidelines' do
        num_completed = 1
        user_some_completed = build(:user, first_name: 'SomeCompleted')
        user_checklist = create(:user_checklist, user: user_some_completed,
                                master_checklist: guideline_master,
                                num_children: 3,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_some_completed)
                                                    .and_return(user_checklist)
        expect(described_class.completed_guidelines_for(user_some_completed).count).to eq num_completed
      end
    end

    context 'all guidelines completed' do
      it 'list all the guidelines' do
        num_completed = 2
        user_all_completed = build(:user, first_name: 'AllCompleted')
        user_checklist = create(:user_checklist, :completed,
                                user: user_all_completed,
                                master_checklist: guideline_master,
                                num_completed_children: num_completed)
        expect(user_checklist.all_completed?).to be_truthy

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_all_completed)
                                                    .and_return(user_checklist)
        expect(described_class.completed_guidelines_for(user_all_completed).count).to eq num_completed
      end
    end
  end

  describe '.not_completed_guidelines_for' do

    it 'empty list if  there is no list for the user' do
      user_no_checklist = build(:user)
      expect(described_class.not_completed_guidelines_for(user_no_checklist)).to be_empty
    end

    context 'no guidelines completed' do
      it 'all of the guidelines' do
        num_children = 2
        num_completed = 0
        user_none_completed = build(:user)
        user_checklist = create(:user_checklist, user: user_none_completed,
                                master_checklist: guideline_master,
                                num_children: num_children,
                                num_completed_children: num_completed)
        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_none_completed)
                                                    .and_return(user_checklist)
        expect(described_class.not_completed_guidelines_for(user_none_completed).count).to eq num_children
      end
    end

    context 'some guidelines completed' do
      it 'list with only the uncompleted guidelines' do
        num_completed = 1
        num_children = 3
        expected_uncompleted = num_children - num_completed
        user_some_completed = build(:user, first_name: 'SomeCompleted')
        user_checklist = create(:user_checklist, user: user_some_completed,
                                master_checklist: guideline_master,
                                num_children: num_children,
                                num_completed_children: num_completed)

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_some_completed)
                                                    .and_return(user_checklist)
        allow(described_class).to receive(:most_recent_membership_guidelines_list_for)
                                    .with(user_some_completed)
                                    .and_return(user_checklist)

        expect(user_checklist.all_that_are_completed.count).to eq 1
        expect(user_checklist.all_that_are_uncompleted.count).to eq 3

        expect(described_class.not_completed_guidelines_for(user_some_completed).count).to eq(expected_uncompleted)
      end
    end

    context 'all guidelines are completed' do
      it 'is empty' do
        num_completed = 2
        user_all_completed = build(:user, first_name: 'AllCompleted')
        user_checklist = create(:user_checklist, :completed,
                                user: user_all_completed,
                                master_checklist: guideline_master,
                                num_completed_children: num_completed)
        expect(user_checklist.all_completed?).to be_truthy

        allow(AdminOnly::UserChecklistFactory).to receive(:create_member_guidelines_checklist_for)
                                                    .with(user_all_completed)
                                                    .and_return(user_checklist)
        expect(described_class.not_completed_guidelines_for(user_all_completed).count).to eq 0
      end
    end
  end

  describe '.checklist_done_on_or_after_latest_membership_start?' do
    let(:latest_membership) { build(:membership, owner: user, first_day: yesterday) }

    let(:most_recent_checklist) { build(:user_checklist, :completed, user: user,
                                        date_completed: completion_date_20200102) }

    it 'false if there is no recent membership for the user' do
      expect(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                      .with(u)
                                      .and_return(nil)
      expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_falsey
    end

    context 'there is a recent membership for the user' do
      before(:each) do
        allow(Memberships::MembershipsManager).to receive(:most_recent_membership)
                                       .with(u)
                                       .and_return(latest_membership)
      end

      it "gets the first day for the user's latest membership" do
        allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                  .with(u)
                                  .and_return(most_recent_checklist)

        expect(latest_membership).to receive(:first_day).and_return(yesterday)
        described_class.checklist_done_on_or_after_latest_membership_start?(u)
      end

      it 'false if there is no recently completed guidelines checklist for the user' do
        allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                  .with(u)
                                  .and_return(nil)

        expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_falsey
      end

      context 'there is a most recently completed guidelines checklist for the user' do
        before(:each) do
          allow(UserChecklist).to receive(:most_recent_completed_top_level_guideline)
                                    .with(u)
                                    .and_return(most_recent_checklist)
        end

        describe 'converts all Times to Dates' do
          it 'can handle comparing the Time of a UserChecklist most recently completed with a Date for the latest membership start date' do
            allow(latest_membership).to receive(:first_day).and_return(yesterday)
            allow(most_recent_checklist).to receive(:date_completed).and_return(Time.zone.now - 1.day)
            expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_truthy
          end

          it 'can handle comparing the Date of a UserChecklist most recently completed with a Time for the latest membership start date' do
            allow(latest_membership).to receive(:first_day).and_return(Time.zone.now - 1.day)
            allow(most_recent_checklist).to receive(:date_completed).and_return(yesterday)
            expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_truthy
          end

          it 'converts both Times to dates (Time of a UserChecklist most recently completed, and Time for the latest membership start date)' do
            allow(latest_membership).to receive(:first_day).and_return(Time.zone.now - 1.day)
            allow(most_recent_checklist).to receive(:date_completed).and_return(Time.zone.now - 1.day)
            expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_truthy
          end
        end

        it 'gets the date the most recently completed checklist was completed' do
          expect(most_recent_checklist).to receive(:date_completed).and_return(yesterday)
          described_class.checklist_done_on_or_after_latest_membership_start?(u)
        end

        it 'false if the checklist was completed before the first day of the recent membership' do
          allow(latest_membership).to receive(:first_day).and_return(yesterday)
          allow(most_recent_checklist).to receive(:date_completed).and_return(yesterday - 1)
          expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_falsey
        end

        it 'true if the checklist was completed on the first day of the recent membership' do
          allow(latest_membership).to receive(:first_day).and_return(yesterday)
          allow(most_recent_checklist).to receive(:date_completed).and_return(yesterday)
          expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_truthy
        end

        it 'true if the checklist was completed after the first day of the recent membership' do
          allow(latest_membership).to receive(:first_day).and_return(yesterday)
          allow(most_recent_checklist).to receive(:date_completed).and_return(yesterday + 1)
          expect(described_class.checklist_done_on_or_after_latest_membership_start?(u)).to be_truthy
        end
      end
    end
  end
end
