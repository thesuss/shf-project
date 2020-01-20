require 'rails_helper'


RSpec.describe UserChecklist, type: :model do

  let(:all_complete_list) { create(:user_checklist, :completed, num_completed_children: 3) }

  let(:three_complete_two_uncomplete_list) {
    checklist_3done_2unfinished = create(:user_checklist, :completed, num_completed_children: 2)
    list_user = checklist_3done_2unfinished.user

    last_item = checklist_3done_2unfinished.children.last
    not_complete1 = create(:user_checklist, user: list_user, list_position: 200, parent: not_complete1)
    last_item.insert(not_complete1)

    not_complete1_child1 = create(:user_checklist, user: list_user, list_position: 201, parent: not_complete1)
    not_complete1.insert(not_complete1_child1)
    checklist_3done_2unfinished
  }


  after(:all) do
    DatabaseCleaner.clean
    UserChecklist.delete_all
    AdminOnly::MasterChecklist.delete_all
    User.delete_all
  end


  describe 'Factory' do

    it 'default factory is valid' do
      expect(build(:user_checklist)).to be_valid
    end

    it 'traits are valid' do
      expect(create(:user_checklist, :completed)).to be_valid
    end

    it 'arguments passed in are valid' do
      expect(build(:user_checklist, name: 'some name')).to be_valid

      parent_item = create(:user_checklist)
      expect(build(:user_checklist, parent: parent_item)).to be_valid

      expect(create(:user_checklist, num_children: 3)).to be_valid
      expect(create(:user_checklist, num_completed_children: 2)).to be_valid

      expect(create(:user_checklist, parent: parent_item, num_children: 2, num_completed_children: 3)).to be_valid
    end
  end


  describe 'Associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:master_checklist) }
  end


  describe 'Scopes (including those as class methods)' do

    describe 'completed' do

      it 'empty if no UserChecklist is completed' do
        create(:user_checklist)
        expect(described_class.completed).to be_empty
      end

      it 'all where date_completed is NOT NULL (not nil)' do
        3.times { create(:user_checklist, :completed) }
        create(:user_checklist)
        expect(described_class.completed.count).to eq 3
      end
    end

    describe 'uncompleted' do
      it 'empty if all UserChecklists are completed' do
        create(:user_checklist, :completed)
        expect(described_class.uncompleted).to be_empty
      end

      it 'all where date_completed is NULL (nil)' do
        3.times { create(:user_checklist) }
        create(:user_checklist, :completed)
        expect(described_class.uncompleted.count).to eq 3
      end
    end

    it 'completed_by_user' do
      checklist_1 = create(:user_checklist, :completed)
      user_1 = checklist_1.user
      2.times { create(:user_checklist, :completed, user: user_1) }

      create(:user_checklist, :completed)

      expect(described_class.completed_by_user(user_1).count).to eq 3
    end

    it 'not_completed_by_user' do
      checklist_1 = create(:user_checklist)
      user_1 = checklist_1.user
      2.times { create(:user_checklist, user: user_1) }

      create(:user_checklist, :completed, user: user_1)

      2.times { create(:user_checklist, :completed) }

      expect(described_class.not_completed_by_user(user_1).count).to eq 3
    end
  end


  describe 'completed?' do

    it 'false if self is not completed' do
      expect(build(:user_checklist).completed?).to be_falsey
    end

    it 'true if self and all children are complete' do
      all_complete_list = create(:user_checklist, :completed, num_completed_children: 3)
      expect(all_complete_list.completed?).to be_truthy
    end

    it 'false if 1 or more children are not complete' do
      expect(three_complete_two_uncomplete_list.completed?).to be_falsey
    end
  end


  describe 'completed' do

    it 'empty list if no items are complete' do
      expect(create(:user_checklist).completed).to be_empty
    end

    it 'returns a list of all items that are completed, including descendents, in order by list_position' do
      result = three_complete_two_uncomplete_list.completed

      expect(result).to include(three_complete_two_uncomplete_list) # includes the root of the tree
      expect(result).to include(three_complete_two_uncomplete_list.children.first)
      expect(result).to include(three_complete_two_uncomplete_list.children.last)
      expect(result).not_to include(three_complete_two_uncomplete_list.children.last.children.first)
      expect(result).not_to include(three_complete_two_uncomplete_list.children.last.children.last)

      result_list_positions = result.map(&:list_position)
      expect(result_list_positions).to match_array([0, 0, 1])
    end
  end


  describe 'uncompleted' do

    it 'empty list if all items are completed' do
      all_complete = create(:user_checklist, :completed, num_completed_children: 1)
      expect(all_complete.uncompleted).to be_empty
    end

    it 'returns a list of all items NOT completed, including descendents, in order by list_position' do
      undone_root = create(:user_checklist)
      list_user = undone_root.user
      done_item = create(:user_checklist, :completed, user: list_user, list_position: 9, parent: undone_root)
      done_sub1_not_complete = create(:user_checklist, user: list_user, list_position: 5, parent: done_item)

      result = undone_root.uncompleted

      expect(result).to include(undone_root)
      expect(result).to include(done_sub1_not_complete)
      expect(result).not_to include(done_item)

      result_list_positions = result.map(&:list_position)
      expect(result_list_positions).to match_array([0, 5])
    end
  end


  it 'size = completed items + uncompleted items' do
    expect(three_complete_two_uncomplete_list.completed.size + three_complete_two_uncomplete_list.uncompleted.size).to eq(5)
  end


  describe 'all_changed_by_completion_toggle' do

    describe 'is set to completed if it is not complete' do
      # ---- use this --------

      context 'has no descendants' do

        it 'is always set to complete' do
          root_no_descendants = create(:user_checklist)
          expect(root_no_descendants.completed?).to be_falsey

          root_no_descendants.all_changed_by_completion_toggle
          expect(root_no_descendants.completed?).to be_truthy
        end

        context 'has no ancestors' do

          it 'is set to completed' do
            root_no_descendants = create(:user_checklist)
            expect(root_no_descendants.completed?).to be_falsey

            root_no_descendants.all_changed_by_completion_toggle
            expect(root_no_descendants.reload.completed?).to be_truthy
          end

          it 'is the only item returned in the list of items changed' do
            root_no_descendants = create(:user_checklist)
            expect(root_no_descendants.completed?).to be_falsey

            expect(root_no_descendants.all_changed_by_completion_toggle).to match_array([root_no_descendants])
          end
        end

        context 'has ancestors' do

          it 'is set to completed' do
            grandchild_no_descendants = create(:user_checklist)

            child = create(:user_checklist)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist)
            root_parent.insert(child)

            grandchild_no_descendants.all_changed_by_completion_toggle
            expect(grandchild_no_descendants.reload.completed?).to be_truthy
          end

          it 'ancestors are also in the list of items changed' do
            grandchild_no_descendants = create(:user_checklist)

            child = create(:user_checklist)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist)
            root_parent.insert(child)

            expect(grandchild_no_descendants.all_changed_by_completion_toggle).to match_array([root_parent, child, grandchild_no_descendants])
          end

          it 'ancestor date_completed is updated even if it was already set' do
            grandchild_no_descendants = create(:user_checklist)

            child = create(:user_checklist, :completed)
            child_original_date_completed = child.date_completed
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent_original_date_completed = root_parent.date_completed
            root_parent.insert(child)

            grandchild_no_descendants.all_changed_by_completion_toggle
            expect(child.reload.date_completed).not_to eq(child_original_date_completed)
            expect(root_parent.reload.date_completed).not_to eq(root_parent_original_date_completed)
          end
        end
      end

      context 'has descendants' do

        describe 'all descendants are complete' do

          it 'is set to completed' do

            greatgrandchild_completed = create(:user_checklist, :completed)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_completed)

            child_one_completed = create(:user_checklist, :completed)

            child_two_completed = create(:user_checklist, :completed)
            child_two_completed.insert(grandchild_completed)

            root = create(:user_checklist)
            root.insert(child_one_completed)
            root.insert(child_two_completed)

            expect(root.completed?).to be_falsey
            root.all_changed_by_completion_toggle
            expect(root.completed?).to be_truthy
          end

          context 'has no ancestors' do

            it 'is the only item returned in the list of items changed' do
              root_no_descendants = create(:user_checklist)
              expect(root_no_descendants.completed?).to be_falsey

              expect(root_no_descendants.all_changed_by_completion_toggle).to match_array([root_no_descendants])
            end
          end

          context 'has ancestors' do

            it 'ancestors are also in the list of items changed' do
              great_grandchild_complete = create(:user_checklist, :completed)

              grandchild = create(:user_checklist)
              grandchild.insert(great_grandchild_complete)

              child = create(:user_checklist)
              child.insert(grandchild)

              root_parent = create(:user_checklist)
              root_parent.insert(child)

              expect(grandchild.all_changed_by_completion_toggle).to match_array([root_parent, child, grandchild])
            end

            it 'ancestor date_completed is updated even if it was already set' do
              great_grandchild_complete = create(:user_checklist, :completed)

              grandchild = create(:user_checklist)
              grandchild.insert(great_grandchild_complete)

              child = create(:user_checklist, :completed)
              child_original_date_completed = child.date_completed
              child.insert(grandchild)

              root_parent = create(:user_checklist, :completed)
              root_parent_original_date_completed = root_parent.date_completed
              root_parent.insert(child)

              grandchild.all_changed_by_completion_toggle
              expect(child.reload.date_completed).not_to eq(child_original_date_completed)
              expect(root_parent.reload.date_completed).not_to eq(root_parent_original_date_completed)
            end
          end

        end


        context 'not all descendants are compelete' do

          it 'is not set to complete' do

            greatgrandchild_not_completed = create(:user_checklist)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_not_completed)

            child_one_not_completed = create(:user_checklist)

            child_two_completed = create(:user_checklist, :completed)
            child_two_completed.insert(grandchild_completed)

            root = create(:user_checklist)
            root.insert(child_one_not_completed)
            root.insert(child_two_completed)

            root.all_changed_by_completion_toggle

            # Must be sure to RELOAD so we get the updates
            expect(root.reload.completed?).to be_falsey
          end

          context 'has no ancestors' do

            it 'is not changed to completed' do

              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_completed = create(:user_checklist, :completed)
              child_completed.insert(grandchild_completed)

              root = create(:user_checklist)
              root.insert(child_completed)

              root.all_changed_by_completion_toggle
              expect(root.reload.completed?).to be_falsey
            end

            it 'the list of items changed is empty' do
              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_completed = create(:user_checklist, :completed)
              child_completed.insert(grandchild_completed)

              root = create(:user_checklist)
              root.insert(child_completed)

              expect(root.all_changed_by_completion_toggle).to be_empty
            end
          end

          context 'has ancestors' do

            it 'is not changed to completed' do
              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_one_not_completed = create(:user_checklist)
              child_one_not_completed.insert(grandchild_completed)

              parent = create(:user_checklist)
              parent.insert(child_one_not_completed)

              child_one_not_completed.all_changed_by_completion_toggle
              expect(child_one_not_completed.reload.completed?).to be_falsey
            end

            it 'no ancestors are in the list of items changed' do
              greatgrandchild_not_completed = create(:user_checklist)
              grandchild_completed = create(:user_checklist, :completed)
              grandchild_completed.insert(greatgrandchild_not_completed)

              child_one_not_completed = create(:user_checklist)
              child_one_not_completed.insert(grandchild_completed)

              root = create(:user_checklist)
              root.insert(child_one_not_completed)

              expect(child_one_not_completed.all_changed_by_completion_toggle).to be_empty
            end
          end

        end

      end

      it 'default is Time.zone.now' do
        originally_not_complete = create(:user_checklist)
        expect(originally_not_complete.completed?).to be_falsey

        completed_time = Time.zone.now
        Timecop.freeze(completed_time) do
          originally_not_complete.all_changed_by_completion_toggle
        end
        expect(originally_not_complete.completed?).to be_truthy
        expect(originally_not_complete.date_completed).to eq completed_time
      end

      it 'sets to the given the time completed' do
        originally_not_complete = create(:user_checklist)
        expect(originally_not_complete.completed?).to be_falsey

        completed_time = Time.new(2020, 02, 20, 20, 20, 00)
        originally_not_complete.all_changed_by_completion_toggle(completed_time)

        expect(originally_not_complete.completed?).to be_truthy
        expect(originally_not_complete.date_completed).to eq completed_time
      end

    end


    describe 'is set to not completed if it was complete' do
      # ---- use this --------

      context 'has no descendants' do

        context 'has no ancestors' do

          it 'is always set to uncomplete' do
            originally_complete = create(:user_checklist, :completed)
            expect(originally_complete.completed?).to be_truthy
            originally_complete.all_changed_by_completion_toggle
            expect(originally_complete.reload.completed?).to be_falsey
          end

          it 'is the only item returned in the list of items changed' do
            originally_complete = create(:user_checklist, :completed)
            expect(originally_complete.completed?).to be_truthy
            expect(originally_complete.all_changed_by_completion_toggle).to match_array([originally_complete])
          end
        end

        context 'has ancestors' do

          it 'is set to completed' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            grandchild_no_descendants.all_changed_by_completion_toggle
            expect(grandchild_no_descendants.reload.completed?).to be_falsey
          end

          it 'only the ancestors changed to "not completed" are in the list of items changed' do
            greatgrandchild_completed = create(:user_checklist, :completed)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_completed)

            child_not_completed = create(:user_checklist)
            child_not_completed.insert(grandchild_completed)

            root_parent_not_completed = create(:user_checklist)
            root_parent_not_completed.insert(child_not_completed)

            expect(greatgrandchild_completed.all_changed_by_completion_toggle).to match_array([grandchild_completed, greatgrandchild_completed])
          end
        end

      end

      context 'has descendants' do

        context 'has no ancestors' do

          it 'is always set to uncomplete' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            root_parent.all_changed_by_completion_toggle
            expect(root_parent.reload.completed?).to be_falsey
          end

          it 'is the only item returned in the list of items changed' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            expect(root_parent.all_changed_by_completion_toggle).to match_array([root_parent])
          end
        end

        context 'has ancestors' do

          it 'is always set to uncomplete' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            child.all_changed_by_completion_toggle
            expect(child.reload.completed?).to be_falsey
          end

          it 'ancestors are also in the list of items changed' do
            grandchild_no_descendants = create(:user_checklist, :completed)

            child = create(:user_checklist, :completed)
            child.insert(grandchild_no_descendants)

            root_parent = create(:user_checklist, :completed)
            root_parent.insert(child)

            child.all_changed_by_completion_toggle
            expect(child.reload.all_changed_by_completion_toggle).to match_array([root_parent, child])
          end

          it 'only the ancestors changed to "not completed" are in the list of items changed' do
            greatgrandchild_completed = create(:user_checklist, :completed)
            grandchild_completed = create(:user_checklist, :completed)
            grandchild_completed.insert(greatgrandchild_completed)

            child_completed = create(:user_checklist, :completed)
            child_completed.insert(grandchild_completed)

            root_parent_not_completed = create(:user_checklist)
            root_parent_not_completed.insert(child_completed)

            expect(grandchild_completed.all_changed_by_completion_toggle).to match_array([child_completed, grandchild_completed])
          end

        end

      end

    end

  end

end
