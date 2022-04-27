class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def edit_status?
    user.admin?
  end

  def show?
    user.admin? || record.id == user.id
  end

  def toggle_membership_package_sent?
    user.admin?
  end

  def proof_of_membership?
    show?
  end

  def view_payment_receipts?
    show?
  end

  def download_payment_receipts_pdf?
    show?
  end
end
