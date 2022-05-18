SELECT users.*,
       users.id                 as user_id,
       business_categories.id   as category_id,
       business_categories.name as category_name,
       business_categories.ancestry,
       shf_applications.id      as application_id -- this is the SHF application that approved this category for this user. Later it might be a CategoryApplication

FROM users,
     business_categories,
     business_categories_shf_applications,
     shf_applications

     --  What happens when a member has more than 1 application?  Should just get the most recent one?

WHERE users.membership_status = 'current_member'
  AND users.admin IS NOT TRUE
  AND shf_applications.user_id = users.id
  AND business_categories_shf_applications.shf_application_id = shf_applications.id
  AND business_categories.id = business_categories_shf_applications.business_category_id


ORDER BY user_id, category_name
