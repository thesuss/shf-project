SELECT "companies".*
FROM "companies"
         INNER JOIN "addresses"
                    ON "addresses"."addressable_id" = "companies"."id"
                        AND "addresses"."addressable_type" = 'Company'
                        AND "addresses"."region_id" IS NOT NULL

WHERE "companies"."name" IS NOT NULL
  AND "companies"."name" <> ''

