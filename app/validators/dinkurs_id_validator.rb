class DinkursIdValidator < ActiveModel::EachValidator
  KEY = 'activerecord.errors.models.company.attributes.dinkurs_company_id.invalid_chars'

  def validate_each(object, attribute, value)
    if value.to_s =~ /å|ä|ö|Å|Ä|Ö/
      object.errors[attribute] << I18n.t(KEY)
    end
  end
end
