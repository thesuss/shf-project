# Helper methods for finding nodes

module FindHelpers

  def for_value_of_label(label_text)
    find(:xpath, "//label[contains(.,'#{label_text}')]")[:for]
  end

end

