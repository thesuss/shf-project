module CompaniesHelper

  def company_complete? company
    !company.nil? && !company.name.nil? && !company.name.empty? &&
      !company.region.nil? && !company.region.empty?
  end
  def list_categories company
    if company.categories.any?
      company.categories.last.name
    end
  end
end
