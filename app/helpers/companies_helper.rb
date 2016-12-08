module CompaniesHelper

  def company_complete? company
    !company.nil? && !company.name.nil? && !company.name.empty? &&
      !company.region.nil? && !company.region.empty?
  end
  def list_categories company
    org = MembershipApplication.find_by(company_number: company.company_number)
    if org.business_categories.any?
      org.business_categories.last.name
    end
  end
end
