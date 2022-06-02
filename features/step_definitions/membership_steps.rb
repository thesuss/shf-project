# Steps for creating and working with Memberships

# This should match any of the following
#  the following memberships exist
#  the following memberships exist:
Given(/^the following memberships exist(?:[:])?$/) do |table|

  table.hashes.each do |membership_line|
    membership_line['membership_number'] = nil if membership_line['membership_number'].blank?
    membership_line['notes'] = nil if membership_line['notes'].blank?

    owner_email = membership_line.delete('email')
    first_day = membership_line.delete('first_day') || nil
    last_day = membership_line.delete('last_day') || nil

    membership_line['owner type'] = 'User' if membership_line['owner type'].blank?
    owner_type = membership_line.delete('owner type').capitalize

    begin
      owner = (owner_type.constantize).find_by(email: owner_email)
    rescue => e
      raise e, "Could not find the #{owner_type} with the email #{owner_email}\n #{e.inspect} in 'the following memberships exist'"
    end

    FactoryBot.create(:membership, owner: owner, first_day: first_day, last_day: last_day)
  end
end


And("I have met all the non-payment requirements for membership") do
  # The date may or may not be provided as an argument
  # @todo replace this with Reqs::AbstractReqsForMembership when there are different types of users that have different requirements for membership (ex. a student membership)
  allow(Reqs::RequirementsForMembership).to receive(:requirements_excluding_payments_met?)
                                        .with(@user)
                                        .and_return(true)
  allow(Reqs::RequirementsForMembership).to receive(:requirements_excluding_payments_met?)
                                        .with(@user, anything)
                                        .and_return(true)
end


And("I have met all the non-payment requirements for renewing my membership") do
  # The date may or may not be provided as an argument
  # @todo may want to mock this when there are more User classes with different renewal requirements (e.g. a student )
  allow(Reqs::RequirementsForRenewal).to receive(:requirements_excluding_payments_met?)
                                     .with(@user)
                                     .and_return(true)
  allow(Reqs::RequirementsForRenewal).to receive(:requirements_excluding_payments_met?)
                                     .with(@user, anything)
                                     .and_return(true)
end
