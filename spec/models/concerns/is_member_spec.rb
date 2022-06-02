require 'rails_helper'

RSpec.describe 'IsMember' do

  # Use TesterClass class to test the behavior of IsMember since we are testing a concern
  #  stub and mock whatever is needed for testing
  class TesterClass
    include IsMember

    attr :membership_changed_info

    def self.connection; end

    def should_send_email
      false
    end

    def membership_status
      'current_membership_status'
    end

    def requirements_for_membership; end

    def requirements_for_renewal; end
  end


  let(:subject) { TesterClass.new }
  let(:described_class) { TesterClass }

  let(:mock_membership_reqs) { double(Reqs::AbstractReqsForMembership) }
  let(:mock_renewal_reqs) { double(Reqs::RequirementsForRenewal) }
  let(:mock_aasm) { double(AASM::Base) }

  before(:each) do
    allow(subject).to receive(:memberships_manager).and_return(instance_double(Memberships::MembershipsManager))
    allow(subject).to receive(:requirements_for_membership).and_return(mock_membership_reqs)
    allow(subject).to receive(:requirements_for_renewal).and_return(mock_renewal_reqs)
    allow(described_class).to receive(:aasm).and_return(mock_aasm)
  end

  it '.membership_statuses is all membership statuses (from aasm)' do
    expect(described_class.aasm).to receive(:states).and_return([])
    described_class.membership_statuses
  end

  it '.memberships_manager_class is Memberships::MembershipsManager' do
    expect(described_class.memberships_manager_class).to eq Memberships::MembershipsManager
  end

  it '.membership_statuses_incl_informational is all membership statuses and the informational statuses' do
    allow(described_class.aasm).to receive(:states).and_return([instance_double(AASM::Core::State, name: 'status 1'), instance_double(AASM::Core::State, name: 'status 2')])
    allow(described_class.memberships_manager_class).to receive(:informational_statuses).and_return(['info 1', 'info 2'])
    expect(described_class.membership_statuses_incl_informational).to match_array(['info 1', 'info 2', 'status 1', 'status 2'])
  end

  it 'has a state machine for the :membership_status' do
    allow(described_class).to receive(:aasm).and_call_original
    expect(described_class.aasm).to be_a(AASM::Base)
    expect(described_class.aasm.state_machine.config.column).to eq(:membership_status)
  end

  describe 'membership_changed' do
    before(:each) do
      allow(subject.aasm).to receive(:from_state).and_return('old membership state')
      allow(subject.aasm).to receive(:to_state).and_return('new membership state')
    end

    it 'sets the Observer status to changed so observers will be notified' do
      expect(subject).to receive(:changed)
      subject.membership_changed
    end

    it 'notifies observers and gives them self, the old membership status, and the new membership status' do
      expect(subject).to receive(:notify_observers).with(subject, 'old membership state', 'new membership state')
      subject.membership_changed
    end

    it 'changes the membership_changed_info to a string with the event that made the change, the old state, and new state' do
      expect(subject.aasm).to receive(:current_event).and_return('event causing change')

      expect(subject.membership_changed_info).to be_nil
      subject.membership_changed
      expect(subject.membership_changed_info).to eq("membership status changed from old membership state to new membership state (event: event causing change)")
    end
  end

  shared_examples 'a membership action' do |method, name|

    it "calls do_actions with #{name} as the action name" do
      expect(subject).to receive(:do_actions).with(name, anything)
      subject.send(method)
    end

    it 'default date is Date.current and default is to send email' do
      expect(subject).to receive(:do_actions).with(name, first_day: Date.current, send_email: true)
      subject.send(method)
    end

    it 'can provide the first_day and whether to send_email' do
      given_date = Date.current + 2.weeks
      expect(subject).to receive(:do_actions).with('New', first_day: given_date, send_email: false)
      subject.start_membership_on(date: given_date, send_email: false)
    end
  end

  describe 'start_membership_on' do
    it_behaves_like 'a membership action', :start_membership_on, 'New'
  end

  describe 'renew_membership_on' do
    it_behaves_like 'a membership action', :renew_membership_on, 'Renew'
  end

  describe 'enter_grace_period' do
    it_behaves_like 'a membership action', :enter_grace_period, 'EnterGracePeriod'
  end

  describe 'become_former_member' do
    it_behaves_like 'a membership action', :become_former_member, 'BecomeFormer'
  end

  describe 'restore_from_grace_period' do
    it_behaves_like 'a membership action', :restore_from_grace_period, 'Restore'
  end

  it 'actions_class_name is Memberships::<action><self class>MemberActions' do
    expect(subject.actions_class_name('blorf action')).to eq "Memberships::BlorfActionTesterClassMemberActions"
  end

  describe 'do_actions' do
    before(:each) { allow(Memberships::MembershipActions).to receive(:for_entity) }

    it 'gets the Action class based on the action name' do
      expect(subject).to receive(:actions_class_name).with('some action').and_return('Memberships::MembershipActions')
      subject.do_actions('some action')
    end

    it 'raises an error if it cannot find the action class' do
      expect(subject).to receive(:actions_class_name).with('some action').and_return('NoSuchClass')
      expect { subject.do_actions('some action') }.to raise_error(NameError)
    end

    it 'sends the action class :for_entity, giving itself, the first day, and whether email should be sent' do
      allow(subject).to receive(:actions_class_name).with('some action').and_return('Memberships::MembershipActions')
      expect(Memberships::MembershipActions).to receive(:for_entity).with(subject, first_day: 'first day', send_email: true)
      subject.do_actions('some action', first_day: 'first day', send_email: true)
    end
  end

  describe 'make_current_member' do
    it 'does nothing if already a current member' do
      allow(subject).to receive(:current_member?).and_return(true)
      expect(subject).not_to receive(:start_membership_on)
      subject.make_current_member
    end

    it 'starts membership on Date.Current' do
      allow(subject).to receive(:current_member?).and_return(false)
      expect(subject).to receive(:start_membership_on).with(date: Date.current)
      subject.make_current_member
    end
  end

  describe 'member_in_good_standing?' do

    it 'default date is Date.current' do
      expect(mock_membership_reqs).to receive(:satisfied?).with(subject, date: Date.current)
      subject.member_in_good_standing?
    end

    it 'is result of requirements_for_membership.satisfied? on the given date' do
      given_date = Date.current - 3.weeks
      expect(mock_membership_reqs).to receive(:satisfied?).with(subject, date: given_date)
      subject.member_in_good_standing?(given_date)
    end
  end

  it 'memberships_manager is a Memberships::MembershipsManager' do
    allow(subject).to receive(:memberships_manager).and_call_original
    expect(subject.memberships_manager).to be_a Memberships::MembershipsManager
  end

  describe 'current_membership' do
    it 'asks the membership manager for the membership today (Date.current)' do
      expect(subject.memberships_manager).to receive(:membership_on).with(subject, Date.current)
      subject.current_membership
    end
  end

  it 'most_recent_membership asks the memberships managre for the most recent membership' do
    expect(subject.memberships_manager).to receive(:most_recent_membership)
    subject.most_recent_membership
  end

  it 'membership_first_day asks the memberships manager for the first day of the most recent membership' do
    expect(subject.memberships_manager).to receive(:most_recent_membership_first_day).with(subject)
    subject.membership_first_day
  end

  it 'membership_last_day asks the memberships manager for the first day of the most recent membership' do
    expect(subject.memberships_manager).to receive(:most_recent_membership_last_day).with(subject)
    subject.membership_last_day
  end

  it 'membership_expires_soon? asks the memberships manager if the given membership expires soon' do
    given_membership = build(:membership)
    expect(subject.memberships_manager).to receive(:expires_soon?).with(subject, given_membership)
    subject.membership_expires_soon?(given_membership)
  end

  it 'membership_expired_in_grace_period? asks the memberships manager if the given membership is in the grace period' do
    given_membership = build(:membership)
    expect(subject.memberships_manager).to receive(:membership_in_grace_period?).with(subject, given_membership)
    subject.membership_expired_in_grace_period?(given_membership)
  end

  it 'membership_past_grace_period_end? asks the memberships manager if the given date is past the end of the grace period for the most recent membership' do
    given_date = Date.current - 3.days
    expect(subject.memberships_manager).to receive(:date_after_grace_period_end?).with(subject, given_date)
    subject.membership_past_grace_period_end?(given_date)
  end

  describe 'membership_status_incl_informational gets the membership status for the given membership' do
    let(:subj_most_recent_membership) { instance_double(Membership) }

    context 'does not expire soon' do
      before(:each) { allow(subject).to receive(:membership_expires_soon?).and_return(false) }

      it 'is the membership status' do
        expect(subject).to receive(:membership_status).and_return('current_membership_status')
        expect(subject.membership_status_incl_informational(subj_most_recent_membership))
          .to eq 'current_membership_status'
      end
    end

    context 'expires soon' do
      before(:each) { allow(subject).to receive(:membership_expires_soon?).and_return(true) }

      it 'is the expires soon status (an informational status; exists for humans only, not the state machine)' do
        allow(subject.memberships_manager).to receive(:expires_soon_status).and_return('expires_soon_status')
        expect(subject.membership_status_incl_informational(subj_most_recent_membership))
          .to eq 'expires_soon_status'
      end
    end
  end

  it 'today_is_valid_renewal_date? asks the memberships manager if today is a valid renewal date' do
    expect(subject.memberships_manager).to receive(:today_is_valid_renewal_date?).with(subject)
    subject.today_is_valid_renewal_date?
  end

  describe 'valid_date_for_renewal? asks the memberships manager if the given date is a valid renewal date' do
    it 'default date is Date.current' do
      expect(subject.memberships_manager).to receive(:valid_renewal_date?).with(subject, Date.current)
      subject.valid_date_for_renewal?
    end

    it 'asks the memberships manager if the given date is a valid renewal date' do
      given_date = Date.current - 2.weeks
      expect(subject.memberships_manager).to receive(:valid_renewal_date?).with(subject, given_date)
      subject.valid_date_for_renewal?(given_date)
    end
  end

  it 'archive_memberships has the memberships manager create archived memberships for all the memberships' do
    expect(subject.memberships_manager).to receive(:create_archived_memberships_for).with(subject)
    subject.archive_memberships
  end

  it 'membership_last_day_has_changed clears the proof of membership image cache' do
    expect(subject).to receive(:clear_proof_of_membership_image_cache)
    subject.membership_last_day_has_changed
  end

  describe 'get_next_membership_number' do
    it 'has the connection execute SQL to SELECT the next value in the membership number sequence' do
      mock_connection = double(ActiveRecord::ConnectionAdapters::AbstractAdapter)
      mock_sql_result = instance_double(PG::Result)
      allow(described_class).to receive(:connection).and_return(mock_connection)
      allow(mock_sql_result).to receive(:getvalue).with(0, 0).and_return('sql result')
      expect(mock_connection).to receive(:execute)
                                   .with("SELECT nextval('membership_number_seq')")
                                   .and_return(mock_sql_result)

      expect(subject.send(:get_next_membership_number)).to eq 'sql result'
    end
  end
end
