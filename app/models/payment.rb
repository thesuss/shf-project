require 'observer'

class Payment < ApplicationRecord

  include Observable

  after_initialize :add_observers
  #  before_destroy :delete_observers  # TODO is this needed?


  belongs_to :user
  belongs_to :company, optional: true # used for branding_fee

  validates_presence_of :user, :payment_type, :status, :start_date, :expire_date
  validates_presence_of :hips_id, on: :update

  PAYMENT_TYPE_MEMBER   = 'member_fee'
  PAYMENT_TYPE_BRANDING = 'branding_fee'

  # This hash maps a HIPS order status to an SHF payment status.
  # The payment values are stored in the DB and exposed to the user.
  # (The user is paying a fee to SHF (payment).  In order to process that
  #  payment, we create a HIPS order and pass that to HIPS, which then
  #  processes that order (that is, has the user pay for the order).
  #  Note that here, "payment" refers to the SHF Payment, and "order" to
  #  the HIPS order).
  # Note that successful order payment (on the HIPS side) is represented by
  # order status 'successful'.  On the SHF side, that translates to a
  # completed payment ('paid') for the user fee (e.g. a membership fee).
  ORDER_PAYMENT_STATUS = {
    nil          => 'skapad',  # created
    'pending'    => 'avvaktan',
    'successful' => 'betald',   # paid
    'expired'    => 'utgånget',
    'awaiting_payments' => 'Väntar på betalning' # awaiting payment
  }.freeze

  CREATED = ORDER_PAYMENT_STATUS[nil]
  PENDING = ORDER_PAYMENT_STATUS['pending']
  SUCCESSFUL = ORDER_PAYMENT_STATUS['successful']
  EXPIRED = ORDER_PAYMENT_STATUS['expired']
  AWAITING_PAYMENTS = ORDER_PAYMENT_STATUS['awaiting_payments']


  NO_HIPS_ID = 'none'

  UNKNOWN_ORDER_STATUS = 'unknown'


  validates :status, inclusion: ORDER_PAYMENT_STATUS.values

  scope :completed, -> { where(status: SUCCESSFUL) }

  scope :unexpired, -> { where('expire_date >= ?', Time.zone.today ) }

  scope PAYMENT_TYPE_MEMBER.to_sym, -> { where(payment_type: PAYMENT_TYPE_MEMBER) }

  scope PAYMENT_TYPE_BRANDING.to_sym, -> { where(payment_type: PAYMENT_TYPE_BRANDING) }


  def add_observers
    add_observer MembershipStatusUpdater.instance, :payment_made
  end



  # return all payments where updated_at: >= start date AND updated_at: <= end_date
  def self.updated_in_date_range(start_date, end_date)
    where( updated_at: start_date..end_date )
  end


  def self.order_to_payment_status(order_status)
    ORDER_PAYMENT_STATUS.fetch(order_status, UNKNOWN_ORDER_STATUS)
  end


  # The transaction was successful.  The transaction might depend on an external system (e.g. HIPS).
  # This method is called so we can do whatever it is we need to do
  # (e.g. set the status, notify observers, etc.).
  def successfully_completed
    self.update(status: SUCCESSFUL)
    changed
    notify_observers(self)
  end

end
