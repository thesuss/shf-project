# Preview all emails at http://localhost:3000/rails/mailers

require_relative 'pick_random_helpers'


class AdminMailerPreview < ActionMailer::Preview

  include PickRandomHelpers


  def new_shf_application_received
    admin = User.find_by(admin: true)

    app = random_shf_app
    upload_random_num_files(app)

    AdminMailer.new_shf_application_received(app, admin)
  end



  def member_unpaid_over_6_months

    num_months = 6
    admin = User.find_by(admin: true)

    past_due_date = (Time.zone.now - num_months.months).to_date

    # create 3 members that are past due more than num_months:
    past_due_members = []
    3.times do | i |
      new_u = User.create(first_name: "Firstname#{i}",
                          last_name: "Lastname-#{i}",
                          email: "email-#{i}-#{Time.now.to_i}@example.com",
                          password: 'whatever',
                          admin: false,
                          member:true)
      new_u.issue_membership_number

      new_app = FactoryBot.create(:shf_application, :accepted, user: new_u)

      new_co            = new_app.companies.first
      new_co.name = "Some Company #{i}" if new_co.name.blank?
      new_co.website = "http://www.woof-#{i}.com"

      # make each one overdue by (i) days + past_due_date so we have some variety
      FactoryBot.create(:membership_fee_payment,
             user: new_u,
             start_date: past_due_date - 364 - i,
             expire_date: past_due_date - i)

      past_due_members << new_u
    end

    AdminMailer.member_unpaid_over_x_months(admin, past_due_members, num_months)

  end


end
