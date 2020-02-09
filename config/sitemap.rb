# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://hitta.sverigeshundforetagare.se"

SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.create do

  # Only add those companies that are searchable. The search engine bots should only
  # crawl those company pages for companyes that would show up on
  # the main list of companies for visitors. This is the 'searchable' scope.
  companies_to_add = Company.searchable
  company_options = Proc.new { |company| { lastmod: company.updated_at, changefreq: 'weekly' } }

  # Default version (and URLs) is the Swedish (svenska) version:
  group(filename: :svenska) do

    add root_path, changefreq: 'daily', priority: 0.8

    companies_to_add.find_each do |co|
      add company_path(co), company_options.call(co)
    end
  end


  # English version:
  # pass in 'locale: :en' to each path to get the English version
  group(filename: :english) do

    add root_path(locale: :en), changefreq: 'daily', priority: 0.7

    companies_to_add.find_each do |co|
      add company_path(co, locale: :en), company_options.call(co)
    end
  end
end
