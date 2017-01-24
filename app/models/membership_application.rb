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

    state :new, :initial => true
    state :under_review
    state :waiting_for_applicant
    state :ready_for_review
    state :accepted
    state :rejected


    event :start_review do
      transitions from: :new, to: :under_review, guard: :not_a_member?
      transitions from: :ready_for_review, to: :under_review
    end

    event :ask_applicant_for_info do
      transitions from: :under_review, to: :waiting_for_applicant
    end

    event :cancel_waiting_for_applicant do
      transitions from: :waiting_for_applicant, to: :under_review
    end

    event :is_ready_for_review do
      transitions from: :waiting_for_applicant, to: :ready_for_review
    end

    event :accept do
      transitions from: [:under_review, :rejected], to: :accepted, guard: [:paid?, :not_a_member?], after: :accept_membership
    end

    event :reject do
      transitions from: [:under_review, :accepted], to: :rejected, after: :reject_membership
    end

  end

  # these are only used by the submisssion form and are not saved to the db
  def marked_ready_for_review
    @marked_ready_for_review ||= (ready_for_review? ? 1 : 0)
  end

  def marked_ready_for_review=(value)
    @marked_ready_for_review = value
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
    is_accepted?
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
