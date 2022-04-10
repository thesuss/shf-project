require_relative('../seed_helpers.rb')
require_relative '../require_all_seeders_and_helpers'

module SeedHelpers
  #--------------------------
  #
  # @class UsersFactory
  #
  # @desc Responsibility: Create Users with specific attributes, etc.
  #
  # @author Ashley Engelund (ashley.engelund@gmail.com  weedySeaDragon @ github)
  # @date   12/10/20
  #
  #--------------------------
  #
  class UsersFactory

    # Used to predefined users and members
    PREDEFINED_NUM_NEWUSERS = 3
    PREDEFINED_NUM_APPLICANTS_EACH_APP_STATE = 2
    PREDEFINED_NUM_MEMBERS = 2
    PREDEFINED_NUM_LAPSEDMEMBERS = 3
    PREDEFINED_NUM_FORMERMEMBERS = 2

    # Percentages used to create random users
    PERCENT_REGISTERED_USERS = 0.1
    PERCENT_CURRENT_MEMBERS = 0.55
    PERCENT_FORMER_MEMBERS = 0.15
    PERCENT_IN_GRACE_PD = 0.2

    RANDOM_INDICATOR = 'Random'

    NEWUSER_LNAME = 'NewUser'

    APPLICANT_LNAME = 'Applicant'

    MEMBER_LNAME = 'Member'
    MEMBER_FNAME_PREFIX = 'Medlem-Exp'

    PAID_THRU_FNAME = 'PaidThrough'

    GRACEPERIODMEMBER_LNAME = 'InGracePeriod'
    GRACEPERIODMEMEBER_FNAME_PREFIX = 'Forsenad-Exp'

    FORMERMEMBER_LNAME = 'FormerMember'
    FORMERMEMBER_FNAME_PREFIX = 'TidigareMedlem-Exp'

    DUMMY_EMAIL_DOMAIN = 'example.com'

    MEMBERSHIP_APP_UPLOADED_FNAME = 'dog_emoji_cocker_spaniel.jpg'

    # --------------------------------------------------------------------------------------------

    def self.term_length_to_days
      Membership.term_length.to_i / 1.day.to_i
    end


    def self.grace_period_to_days
      MembershipsManager.grace_period.to_i / 1.day.to_i
    end

    def self.default_payment_processor
       Payment.payment_processor_klarna
    end

    # --------------------------------------------------------------------------------------------

    def initialize(static_data = SeedHelpers::StaticDataFactory.new, log = nil)
      @static_data = static_data
      @log = log
      @shf_application_factory = ::SeedHelpers::ShfApplicationFactory.new(static_data, log)
      @payments_factory = ::SeedHelpers::PaymentsFactory.new(static_data, log)
    end


    def seed_users_and_members(num_random = 0)
      seed_predefined_users(@log)
      seed_random_users(num_random, @log)
    end


    def seed_predefined_users(log = nil)
      log.info('Creating predefined users and members.') if log
      make_predefined_new_registered_users
      make_predefined_applicants
      make_predefined_current_members
      make_predefined_in_grace_period_members
      make_predefined_former_members
    end


    def seed_random_users(num_users = 0, log = nil)
      return if num_users == 0

      log.info("Creating #{num_users} random users and members. (This number can be set with ENV['SHF_SEED_USERS'])...") if log

      # users with no application (or zero if we are creating fewer than 3 total)
      users_with_no_application = num_users < 3 ? 0 : [1, (PERCENT_REGISTERED_USERS * num_users).round].max
      make_random_new_registered_users(users_with_no_application)

      users_with_application = num_users - users_with_no_application
      return if users_with_application == 0

      num_current_members = (users_with_application * PERCENT_CURRENT_MEMBERS).round
      make_random_current_members(num_current_members)
      num_former_members = (users_with_application * PERCENT_FORMER_MEMBERS).round
      make_random_former_members(num_former_members)
      num_in_grace_pd = (users_with_application * PERCENT_IN_GRACE_PD).round
      make_random_in_grace_period_members(num_in_grace_pd)

      # the rest should be applicants, the application status chosen at random (excluding 'accepted')
      num_applicants = users_with_application - num_current_members -
        num_former_members - num_in_grace_pd
      make_random_applicants(num_applicants) unless num_applicants == 0
    end


    # New users are those that have signed up, but not submitted any application or done anything else.
    #   (They have not agreed to any Ethical Guidelines, etc.)
    # @return [Array<User>] The users created.
    def make_predefined_new_registered_users
      make_predefined_with(lastname: NEWUSER_LNAME, number: PREDEFINED_NUM_NEWUSERS)
    end


    # Applicants have created a new application (but the application has not been reviewed).  Some
    #   percentage have done 'other' requirements. (As of 2021-06-2,there are 2 'other'
    #   requirements:  agree to the Ethical Guidelines and upload at least 1 document.
    #   But there could be additional requirements in the future.)
    #
    # ShfApplications and Companies are created for the applicants
    # Make PREDEFINED_NUM_APPLICANTS_EACH_APP_STATE applicants for each application state
    # @return [Array<User>] The applicants created.
    def make_predefined_applicants
      new_applicants = []
      app_states_except_being_destroyed = ShfApplication.aasm.states.map(&:name) - [:being_destroyed]
      app_states_except_being_destroyed.each do |application_state|
        app_state_i18n = ShfApplication.human_attribute_name("state.#{application_state}")
        new_applicants.concat(make_predefined_with(lastname: APPLICANT_LNAME,
                                                   firstname: app_state_i18n.capitalize,
                                                   number: PREDEFINED_NUM_APPLICANTS_EACH_APP_STATE)) do |applicant|
          @shf_application_factory.make_n_save_app(applicant, application_state)
        end
      end
      new_applicants
    end


    # Current members are those that have met all of the requirements for membership and have
    # paid.  Some percentage have paid in advance (for more than 1 membership term).
    # ShfApplications and Companies are created for the members.
    # @return [Array<User>] The members created.
    def make_predefined_current_members
      make_members_paid_through(Date.current + 1.day)
      make_members_paid_through(Date.current + 1.month)

      earliest_renew_days = MembershipsManager.days_can_renew_early
      make_members_paid_through(Date.current + earliest_renew_days)
      make_members_paid_through(Date.current + earliest_renew_days + 1)

      can_renew_term_first_day = Date.current + earliest_renew_days - 1
      renew_minus_1_members = make_members_paid_through(can_renew_term_first_day, number: 3)

      # add past memberships and payments to this member
      renew_minus_1_member_last = renew_minus_1_members.last
      create_past_memberships_for(renew_minus_1_member_last, 4)
      renew_minus_1_member_last.update(email: "has-past-#{renew_minus_1_member_last.email}")

      pd_thru_6_months_members = make_members_paid_through(Date.current + 6.months)
      # add past memberships and payments to this member, including pending payments
      last_pd_thru_6_months_member = pd_thru_6_months_members.last
      create_past_memberships_for(last_pd_thru_6_months_member, 6)
      oldest_membership = last_pd_thru_6_months_member.memberships.sort_by(&:first_day).first
      3.times{ @payments_factory.new_klarna_pending_membership_payment(last_pd_thru_6_months_member,
                                                                       oldest_membership.first_day,
                                                                       oldest_membership.last_day) }

      last_pd_thru_6_months_member.update(email: "has-past-pending-#{last_pd_thru_6_months_member.email}")


      make_members_paid_through(Date.current + 2.years - 1.day, term_first_day: Date.current)
    end


    # Members with payments overdue are those who are in the 'grace period'.
    # They may or may not have completed all of the requirements for renewing membership for the
    # membership term. Ex: If the requirement for renewing membership includes "must upload at least
    # 1 file" they may or may not have done that.  The requirements for renewing membership are
    # separate from payments.
    # @return [Array<User>] The members created.
    def make_predefined_in_grace_period_members
      grace_pd_first_day = Date.current - MembershipsManager.grace_period + 1.day
      firstname_start = 'GracePeriod-since'
      make_members_paid_through(grace_pd_first_day, lastname: GRACEPERIODMEMBER_LNAME,
                                firstname_prefix: firstname_start)
      make_members_paid_through(grace_pd_first_day + 1.month, lastname: GRACEPERIODMEMBER_LNAME,
                                firstname_prefix: firstname_start)
      make_members_paid_through(Date.today - 1.day, lastname: GRACEPERIODMEMBER_LNAME,
                                firstname_prefix: firstname_start)
    end


    # Former members are those whose last payment date has past AND they are past the 'grace period'
    #   as well.
    # @return [Array<User>] The members created.
    def make_predefined_former_members
      most_recent_last_day = Date.current - MembershipsManager.grace_period
      make_members_paid_through(most_recent_last_day - 1.day,
                                lastname: FORMERMEMBER_LNAME,
                                firstname_prefix: FORMERMEMBER_FNAME_PREFIX)
      make_members_paid_through(most_recent_last_day - 2.days,
                                lastname: FORMERMEMBER_LNAME,
                                firstname_prefix: FORMERMEMBER_FNAME_PREFIX)
    end


    # @return [Array<User>] The members created.
    def make_random_new_registered_users(num_users = 1)
      return if num_users == 0

      make_predefined_with(lastname: name_with_random(NEWUSER_LNAME), number: num_users)
    end


    # @return [Array<User>] The applicants created.
    def make_random_applicants(num_applicants = 1)
      return [] if num_applicants == 0

      new_applicants = []
      num_applicants.times do
        new_applicants.concat(make_predefined_with(firstname: FFaker::NameSE.first_name,
                                                   lastname: name_with_random(APPLICANT_LNAME))) do |applicant|
          @shf_application_factory.make_n_save_app(applicant, random_application_not_accepted_state)
        end
      end
      new_applicants
    end


    # @return [Array<User>] The members created.
    def make_random_current_members(num_members = 1)
      return [] if num_members == 0

      new_members = []
      term_length_days = self.class.term_length_to_days
      num_members.times do |i|
        days_left_in_term = Random.rand(0..(term_length_days - 1))
        # days_left_in_term = Random.rand(0..([term_length_days - 1, 0].max))
        new_members.concat(make_members_paid_through(Date.current + days_left_in_term.day,
                                                     firstname_prefix: "#{MEMBER_FNAME_PREFIX}#{i}",
                                                     lastname: name_with_random(MEMBER_LNAME)))
      end
      new_members
    end


    # @return [Array<User>] The members created.
    def make_random_in_grace_period_members(num_grace_pds = 1)
      return [] if num_grace_pds == 0

      new_members = []
      grace_pd_days = self.class.grace_period_to_days
      num_grace_pds.times do |i|
        last_day = Date.current - Random.rand(1..([grace_pd_days - 1, 1].max))
        new_members.concat(make_members_paid_through(last_day,
                                                     firstname_prefix: "#{GRACEPERIODMEMEBER_FNAME_PREFIX}#{i}",
                                                     lastname: name_with_random(GRACEPERIODMEMBER_LNAME)))
      end
      new_members
    end


    # @return [Array<User>] The members created.
    def make_random_former_members(num_former_members = 1)
      return [] if num_former_members == 0

      new_members = []
      num_former_members.times do |i|
        last_day = Date.current - MembershipsManager.grace_period - (Random.rand(1..700))
        new_members.concat(make_members_paid_through(last_day,
                                                     firstname_prefix: "#{FORMERMEMBER_FNAME_PREFIX}#{i}",
                                                     lastname: name_with_random(FORMERMEMBER_LNAME)))
      end
      new_members
    end


    # @return [Array<User>] The new members created.
    def make_members_paid_through(term_last_day, lastname: MEMBER_LNAME,
                                  number: 1,
                                  firstname_prefix: PAID_THRU_FNAME,
                                  term_first_day: nil,
                                  membership_status: :current_member)
      make_predefined_with(lastname: lastname, number: number, firstname: "#{firstname_prefix}-#{term_last_day.iso8601}") do |member|
        term_first_day = term_first_day.nil? ? Membership.first_day_from_last(term_last_day) : term_first_day

        @shf_application_factory.make_n_save_app(member, MA_ACCEPTED_STATE, acceptance_date: term_first_day)
        member.reload

        upload_membership_application_file(member, member.shf_application,
                                           MEMBERSHIP_APP_UPLOADED_FNAME,
                                           term_first_day - 1)

        make_completed_membership_guidelines_for(member, term_first_day - 1)
        # Make payments
        member.payments << @payments_factory.new_klarna_membership_payment(member, term_first_day, term_last_day)
        member.companies.first.payments << @payments_factory.new_klarna_hmarkt_payment(member, term_first_day, term_last_day)

        if member.current_membership
          member.most_recent_membership&.update(first_day: term_first_day, last_day: term_last_day)
        else
          member.start_membership_on(date: term_first_day, send_email: false)
        end
        member.update(membership_status: membership_status)
        member.reload

        MembershipStatusUpdater.instance.update_membership_status(member, send_email: false)
        member
      end
    end


    # @return [Array<User>] The users created.
    def make_predefined_with(lastname: 'Someone', number: 1, firstname: nil)
      return if number == 0
      new_users = []
      number.times do |i|
        user = new_user(lastname, number: i, firstname: firstname)
        yield(user) if block_given?
        new_users << user
      end
      new_users
    end


    # Create past memberships (and the requirements) for the user.
    # Make the payments for the last (oldest) use the HIPS payment processor
    # @return [User] The user that memberships were created for
    def create_past_memberships_for(user, num_memberships = 1)
      oldest_first_day = user.memberships.sort_by(&:first_day).first.first_day.to_date
      new_first_day = oldest_first_day - Membership.term_length
      num_memberships.times do |i|
        payment_processor = ((i == num_memberships - 1) ? Payment.payment_processor_hips : self.class.default_payment_processor)
        create_membership_and_requirements_for(user, term_first_day: new_first_day, payment_processor: payment_processor)
        new_first_day = new_first_day - Membership.term_length
      end
      user
    end


    # Create all the things needed for a membership (payments, etc), create the new membership,
    # add the things to the user and return the user.
    # Note: This _does NOT update the membership status for the user._ The calling method can do it if appropriate.
    #
    # @return User
    def create_membership_and_requirements_for(user, term_first_day: Date.current,
                                               payment_processor: Payment.payment_processor_klarna)
      make_completed_membership_guidelines_for(user, term_first_day)

      if payment_processor == Payment.payment_processor_klarna
        new_membership_payment_method = :new_klarna_membership_payment
        new_hmarkt_payment_method = :new_klarna_hmarkt_payment
      else
        new_membership_payment_method = :new_hips_membership_payment
        new_hmarkt_payment_method = :new_hips_hmarkt_payment
      end

      term_last_day = Membership.last_day_from_first(term_first_day)
      user.payments << @payments_factory.send(new_membership_payment_method, user, term_first_day, term_last_day)
      user.companies.first.payments << @payments_factory.send(new_hmarkt_payment_method, user, term_first_day, term_last_day)

      user.memberships << Membership.create!(user: user, first_day: term_first_day, last_day: term_last_day)

      user.reload
      user
    end


    # @return [User] - created with the given last name, and email and firstname based on the last name
    #   and number.
    def new_user(lastname = 'SomeUser', number: 1, firstname: nil)
      human_num = number + 1 # don't use zero based because it may be confusing for testers that aren't nerdy developers
      fname = firstname.blank? ? firstname_from_lastname_num(lastname, human_num) : name_with_num(firstname, human_num)
      new_email = email_from_firstname(fname)

      raise "Could not create new user #{new_email}. That email is already taken." if User.all.pluck(:email).include?(new_email)

      User.create!(email: new_email,
                   password: DEFAULT_PASSWORD,
                   first_name: fname,
                   last_name: lastname)
    end


    # @return [String] - append a hyphen then the RANDOM string to the name
    def name_with_random(name = '', separator: '-')
      "#{name}#{separator}#{RANDOM_INDICATOR}"
    end


    def firstname_from_lastname_num(lastname, num = 1)
      name_with_num(lastname, num)
    end


    def name_with_num(name, num = 1)
      "#{name}-#{num}"
    end


    def email_from_firstname(firstname)
      "#{firstname.gsub(/(\s)+/, '-').downcase}@#{DUMMY_EMAIL_DOMAIN}"
    end


    # @return [Symbol] - a randomly chosen ShfApplication state, excluding :accepted and :being_destroyed
    #
    def random_application_not_accepted_state
      states = ShfApplication.aasm.states.map(&:name) -
        [MA_ACCEPTED_STATE, MA_BEING_DESTROYED_STATE]
      FFaker.fetch_sample(states)
    end


    # Create the Ethical Guidelines checklist and complete it
    def make_completed_membership_guidelines_for(user, completion_date)
      guidelines_list = UserChecklistManager.find_or_create_membership_guidelines_list(user)
      guidelines_list.set_complete_including_children(completion_date)
      # set created_at date to the completion_date because UserChecklistManager checks it
      guidelines_list.update(created_at: completion_date)
      guidelines_list.descendants.update_all(created_at: completion_date)
    end


    def upload_membership_application_file(user, membership_app,
                                           uploaded_filename = MEMBERSHIP_APP_UPLOADED_FNAME,
                                           file_created_at)
      File.open(File.join(__dir__, uploaded_filename), 'r') do |f|
        uploaded_file = UploadedFile.create!(user: user,
                                             shf_application: membership_app,
                                             actual_file: f,
                                             actual_file_file_name: uploaded_filename)
        membership_app.uploaded_files << uploaded_file

        uploaded_file.update(actual_file_updated_at: file_created_at,
                             created_at: file_created_at, updated_at: file_created_at)
      end
    end


  end

end
