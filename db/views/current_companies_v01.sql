SELECT companies.*,
       companies.id AS company_id
--        addresses.id as address_id

-- @todo How can we reference a subquery or a different DB view?
FROM companies

WHERE companies.id IN
      (SELECT companies.id
       FROM companies,
            users,
            company_applications,
            shf_applications

       WHERE users.membership_status = 'current_member'
         AND shf_applications.user_id = users.id
         AND shf_applications.state = 'accepted'
         AND company_applications.shf_application_id = shf_applications.id
         AND companies.id = company_applications.company_id)

  AND companies.id IN (SELECT companies.id
                       FROM companies,
                            payments
                       WHERE payments.payment_type = 'branding_fee'
                         AND payments.status = 'betald'
                         AND payments.expire_date >= now()
                         AND payments.company_id = companies.id)

--   AND addresses.addressable_id = companies.id

ORDER by companies.id
