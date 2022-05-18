SELECT current_companies.*,
       member_and_categories.category_id,
       member_and_categories.category_name,
       member_and_categories.application_id,
       member_and_categories.ancestry

FROM current_companies,
     company_and_members,
     member_and_categories

WHERE company_and_members.company_id = current_companies.company_id
    AND member_and_categories.user_id = company_and_members.user_id


ORDER BY company_id, category_name
