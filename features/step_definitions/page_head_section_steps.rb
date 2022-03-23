# -------------------------------------------
# Information in the <head> portion of a page
#
#

# ---------------
# <title >  (page title)
#
Then("the page title should{negate} be {capture_string}") do | negate, page_title |
  expect(page).send (negate ? :not_to : :to), have_title(page_title)
end

# ---------------
# <head > </head>  (page head)
#
Then("the page head should{negate} include meta {capture_string} {capture_string} with content = {capture_string}") do | negate, meta_tag, value, meta_content|
  meta_xpath = "/html/head/meta[@#{meta_tag}=\"#{value}\"]/@content"
  found_meta_tag  = page.find(meta_xpath, visible: false)

  if negate.nil?
    expect(found_meta_tag.text(:all)).to eq meta_content
  else
    # have to pass :all to .text to get text that is not visible
    expect(found_meta_tag && (found_meta_tag.text(:all) == meta_content)).to be_falsey
  end
end


# This uses *match* to compare the value of the meta item with the given string.
# This can be used when you can't know the exact fingerprinting that will be
# added to the end of a file name, for example.
Then("the page head should{negate} include meta {capture_string} {capture_string} with content matching {capture_string}") do | negate, meta_tag, value, meta_content|
  meta_xpath = "/html/head/meta[@#{meta_tag}=\"#{value}\"]/@content"
  found_meta_tag  = page.find(meta_xpath, visible: false)

  if negate.nil?
    expect(found_meta_tag.text(:all)).to match meta_content
  else
    # have to pass :all to .text to get text that is not visible
    expect(found_meta_tag && (found_meta_tag.text(:all) == meta_content)).to be_falsey
  end
end


Then("the page head should{negate} include meta {capture_string} {capture_string}") do | negate, meta_tag, value |
  meta_xpath = "/html/head/meta[@#{meta_tag}=\"#{value}\"]/@content"
  expect(page).send (negate ? :not_to : :to), have_xpath(meta_xpath, visible: false)
end

# ---------------
# <link rel='alternate' hreflang=  href= >  (link hreflang href)
#
Then("the page head should{negate} include a link tag with hreflang = {capture_string} and href = {capture_string}") do | negate, hreflang, href |
  hreflang_xpath = "/html/head/link[@rel='alternate'][@hreflang='#{hreflang}'][@href='#{href}']"
  expect(page).send (negate ? :not_to : :to), have_xpath(hreflang_xpath, visible: false)
end


Then("the page head should{negate} include a link tag with rel = {capture_string} and href = {capture_string}") do | negate, rel, href |
  hreflang_xpath = "/html/head/link[@rel='#{rel}'][@href='#{href}']"
  expect(page).send (negate ? :not_to : :to), have_xpath(hreflang_xpath, visible: false)
end


# This step uses regex to *match* the value of the link href=  with a given string.
# This can be used when you can't know the exact fingerprinting that will be
# added to the end of a file name, for example.
Then("the page head should{negate} include a link tag with rel = {capture_string} and href matching {capture_string}") do | negate, rel, href |
  href_xpath = "/html/head/link[@rel='#{rel}'][@href]"
  expect(page).send (negate ? :not_to : :to), have_xpath(href_xpath, visible: false)

  unless negate
    href_in_page = page.find(:xpath, href_xpath, visible: false)
    expect(href_in_page[:href]).to match(href)
  end
end


# ---------------
# <script type='application/ld+json'>  (ld+json script tag)
#
And("the page head should{negate} include a ld+json script tag with key {capture_string}") do | negate, key |
  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
end


And("the page head should{negate} include a ld+json script tag with key {capture_string} and value {capture_string}") do | negate, key, value |

  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
  expect(ld_json[key]).to eq value
end


And("the page head should{negate} include a ld+json script tag with key {capture_string} and subkey {capture_string} and value {capture_string}") do | negate, key, subkey, value |

  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
  expect(ld_json[key].key?(subkey)).to be_truthy
  expect(ld_json[key][subkey]).to eq value
end


And("the page head should{negate} include a ld+json script tag with key {capture_string} and subkey {capture_string} and subkey2 {capture_string} and value {capture_string}") do | negate, key, subkey1, subkey2, value |

  ld_json = expect_head_has_ld_json_script(negated: negate)

  expect(ld_json.key?(key)).to be_truthy
  expect(ld_json[key].key?(subkey1)).to be_truthy
  expect(ld_json[key][subkey1].key?(subkey2)).to be_truthy
  expect((ld_json[key][subkey1][subkey2]).to_s).to eq value
end


def expect_head_has_ld_json_script(negated: false)
  ld_json_text_xpath  = "/html/head/script[@type='application/ld+json']/text()"
  expect(page).send (negated ? :not_to : :to), have_xpath(ld_json_text_xpath, visible: false)

  ld_json = nil
  unless negated
    ld_json_node = find(:xpath, ld_json_text_xpath, visible: false)
    ld_json_text = ld_json_node.text(:all)

    ld_json = JSON.parse(ld_json_text)

    expect(ld_json.key?('@context')).to be_truthy
    expect(ld_json['@context']).to eq 'http://schema.org'

    expect(ld_json.key?('@type')).to be_truthy
    expect(ld_json['@type']).to eq 'LocalBusiness'

    expect(ld_json.key?('@id')).to be_truthy
  end

  ld_json
end


# ---------------
# <html>  (html tag)
#
And("the html tag should{negate} include lang={capture_string}") do | negate,  lang_attrib|
  lang_xpath = "/html[@lang=\"#{lang_attrib}\"]"
  expect(page).send((negate ? :not_to : :to),  have_xpath(lang_xpath, visible: false))
end


And("the html tag should{negate} include xml\.lang={capture_string}") do | negate,  xml_lang_attrib|
  lang_xpath = "/html[@xml.lang=\"#{xml_lang_attrib}\"]"
  expect(page).send((negate ? :not_to : :to),  have_xpath(lang_xpath, visible: false))
end
