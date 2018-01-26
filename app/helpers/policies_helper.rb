module PoliciesHelper
  def is_in_company?(company)
    user.in_company_numbered?(company.company_number)
  end
end
