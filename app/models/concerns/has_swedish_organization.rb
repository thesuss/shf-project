module HasSwedishOrganization

  extend ActiveSupport::Concern

  included do

    def swedish_organisationsnummer
      errors.add(:company_number, "#{self.company_number} is not a valid company number") unless Orgnummer.new(self.company_number).valid?
    end

  end
end