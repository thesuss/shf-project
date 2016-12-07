module CompaniesHelper

  def company_complete? company

    # company.name != '' && company.region != ''

    company.name && !company.name.empty? &&
      company.region && !company.region.empty?
  end

end
