SELECT users.*,
       users.id             AS user_id,
       companies.id         AS company_id,
       companies.name       AS company_name,
       companies.email      AS company_email,
       companies.website    AS company_website,
       companies.company_number,
       companies.created_at AS companies_created_at,
       companies.updated_at AS companies_updated_at

FROM users,
     companies,
     company_applications,
     shf_applications

-- @todo Note that this gets ALL companies, regardless of company status
WHERE users.membership_status = 'current_member'
  AND shf_applications.user_id = users.id
  AND shf_applications.state = 'accepted'
  AND company_applications.shf_application_id = shf_applications.id
  AND companies.id = company_applications.company_id

ORDER BY user_id, company_id
