# Steps for Master Checklist items


def create_guidelines_list_type_if_needed
  if AdminOnly::MasterChecklistType.membership_guidelines_type.nil?
    AdminOnly::MasterChecklistType.create(name: AdminOnly::MasterChecklistType::MEMBER_GUIDELINES_LIST_TYPE,
                                          description: 'Membership Ethical Guidelines')
  end
end


And(/^the following Master Checklist exist:$/) do |table|

  table.hashes.each do |item|
    name = item.delete('name') || ''
    displayed_text = item.delete('displayed_text') || ''
    description = item.delete('description') || ''
    list_position = (item.delete('list position') || '0').to_i
    parent_name = item.delete('parent name') || ''

    type_name = item.delete('list type name') || ''

    create_guidelines_list_type_if_needed

    list_type = if type_name.blank?
                  AdminOnly::MasterChecklistType.membership_guidelines_type
                else
                  l_type = AdminOnly::MasterChecklistType.find_by(name: type_name)
                  l_type.nil? ? AdminOnly::MasterChecklistType.membership_guidelines_type : l_type
                end

    AdminOnly::MasterChecklist.find_or_create_by(name: name) do
      FactoryBot.create(:master_checklist, name: name,
                        master_checklist_type: list_type,
                        displayed_text: displayed_text,
                        description: description,
                        parent_name: parent_name,
                        list_position: list_position)
    end
  end




end


And(/^the Membership Ethical Guidelines Master Checklist exists$/) do
  create_guidelines_list_type_if_needed

  list_type = AdminOnly::MasterChecklistType.membership_guidelines_type

  AdminOnly::MasterChecklist.find_or_create_by(name: name) do
    FactoryBot.create(:master_checklist, name: list_type.name,
                      master_checklist_type: list_type,
                      displayed_text: list_type.name,
                      description: list_type.description,
                      list_position: 0)
  end
end
