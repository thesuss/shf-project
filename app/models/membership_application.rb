class MembershipApplication < ApplicationRecord
  belongs_to :user
  belongs_to :company, optional: true

  has_and_belongs_to_many :business_categories
  has_many :uploaded_files

  validates_presence_of :first_name,
                        :last_name,
                        :company_number,
                        :contact_email,
                        :state

  validates_length_of :company_number, is: 10
  validates_format_of :contact_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: [:create, :update]
  validate :swedish_organisationsnummer

  accepts_nested_attributes_for :uploaded_files, allow_destroy: true


  include AASM

  aasm :column => 'state' do

    state :under_review, :initial => true
    state :waiting_for_applicant
    state :accepted
    state :rejected


    event :reject do
      after do
        reject_membership
      end
      transitions from: [:under_review, :waiting_for_applicant, :accepted], to: :rejected
    end

    event :accept do
      after do
        accept_membership
      end
      # if a mistake was made and the application should have been accepted, can change it to accept
      transitions from: [:under_review, :rejected], to: :accepted, guard: [:paid?, :not_a_member?]
    end

    event :ask_applicant_for_info do
      transitions from: [:under_review, :rejected], to: :waiting_for_applicant, guard: :not_a_member?
    end

    event :cancel_waiting_for_applicant do
      transitions from: [:waiting_for_applicant], to: :under_review
    end

    event :applicant_updated_info do
      transitions from: [:accepted, :rejected, :waiting_for_applicant, :under_review], to: :under_review, guard: :not_a_member?
    end

  end


  def swedish_organisationsnummer
    errors.add(:company_number, "#{self.company_number} är inte ett svenskt organisationsnummer") unless Orgnummer.new(self.company_number).valid?
  end


  def is_accepted?
    accepted?
  end


  def paid?
    true
    #(total_outstanding_charges <= 0)
  end



  def not_a_member?
    !is_member?
  end


  def is_member?
    user && user.is_member?
  end


  def accept_membership
    begin
      user.update(is_member: true)

      begin
        company = Company.find_or_create_by!(company_number: company_number) { | co| co.email = contact_email }
      rescue ActiveRecord::RecordNotUnique
        retry
      end

      update(company: company)
      save

    rescue => e
      puts "ERROR: could not accept_membership.  error: #{e.inspect}"
      raise e
    end
  end


  def reject_membership
    delete_uploaded_files
  end


  private

  def delete_uploaded_files
    uploaded_files.each do |uploaded_file|
      uploaded_file.actual_file = nil
      uploaded_file.destroy
    end

    save
  end


end
