require 'rails_helper'
include ApplicationHelper

# Since AncestryHelper is a module, we test it using a class that includes it
# AdminOnly::MasterChecklist includes it and so is used to test the class.
#
RSpec.describe AncestryHelper, type: :helper do

  describe 'arranged_tree_as_list' do

    let(:class_that_includes) { AdminOnly::MasterChecklist }

    let(:simple_user) { create(:user) }

    let(:greatgrandchild) { create(:master_checklist, name: 'greatgrandchild', displayed_text: 'greatgrandchild 1') }

    let(:grandchild) do
      gchild = create(:master_checklist, name: 'grandchild', displayed_text: 'grandchild 1')
      gchild.insert(greatgrandchild)
      gchild
    end

    let(:child) do
      c = create(:master_checklist, name: 'child_one', displayed_text: 'child 1')
      c.insert(grandchild)
      c
    end

    let(:root) do
      r = create(:master_checklist, name: 'root', displayed_text: 'root')
      r.insert(child)
      r
    end

    let(:another_top_level_list) { create(:master_checklist, name: 'another top level list') }

    let(:arranged_tree) { class_that_includes.arrange_nodes([greatgrandchild, grandchild, child, root, another_top_level_list]) }

    let(:block_to_generate_content) { lambda { |master_checklist| "name: #{master_checklist.name}" } }

    let(:expected_result_with_default_options) { '<ul class=""><li id="li-db-id-x" class="">name: root<ul class="" id="ul-db-id-x"><li id="li-db-id-x" class="">name: child_one<ul class="" id="ul-db-id-x"><li id="li-db-id-x" class="">name: grandchild<ul class="" id="ul-db-id-x"><li id="li-db-id-x" class="">name: greatgrandchild</li></ul></li></ul></li></ul></li><li id="li-db-id-x" class="">name: another top level list</li></ul>' }

    ID_STR_PATTERN = /db-id-(\d*)/
    BLOTTED_OUT_ID_STR = 'db-id-x'
    # --------------------------------------------------------------------


    describe 'uses options passed in' do

      it 'checks :list_style and then sets (hardcoded) options for it' do
        result = helper.arranged_tree_as_list(arranged_tree, { list_style: :bootstrap_list_group }, &block_to_generate_content)
        expect(result.gsub(ID_STR_PATTERN, BLOTTED_OUT_ID_STR)).to eq expected_result_with_default_options.gsub('<ul class=""', '<ul class="list-group"').gsub(/<li([^>]*)class="">/, '<li\1class="list-group-item">')
      end
    end


    it 'calls the block passed in to generate the content for each entry' do
      result = helper.arranged_tree_as_list(arranged_tree, &block_to_generate_content)
      expect(result.gsub(ID_STR_PATTERN, BLOTTED_OUT_ID_STR)).to eq expected_result_with_default_options
    end


    describe 'if an entry has children' do

      it 'creates a list for all of the children using the options[:list_type]' do
        result = helper.arranged_tree_as_list(arranged_tree, { list_type: 'zz' }, &block_to_generate_content)
        expect(result.gsub(ID_STR_PATTERN, BLOTTED_OUT_ID_STR)).to eq expected_result_with_default_options.gsub('<ul', '<zz').gsub('ul>', 'zz>')
      end

      it 'generates the html for each child by calling arranged_tree_as_list for each child' do
        expect(helper).to receive(:arranged_tree_as_list).exactly(4).times.and_call_original
        helper.arranged_tree_as_list(arranged_tree, &block_to_generate_content)
      end


      describe 'list (ul) classes' do

        it 'adds the options[:ul_class] to the classes for the list (usually a ul element)' do
          result = helper.arranged_tree_as_list(arranged_tree, { ul_class: ['this', 'that'] }, &block_to_generate_content)
          expect(result.gsub(ID_STR_PATTERN, BLOTTED_OUT_ID_STR)).to eq expected_result_with_default_options.gsub('<ul class=""', '<ul class="this that"')
        end

        it 'if the list is at the top level, adds the options[:ul_class_top] classes to the list of classes' do
          result = helper.arranged_tree_as_list(arranged_tree, { ul_class_top: ['tippy', 'top'] }, &block_to_generate_content)
          expect(result.split('<ul class="tippy top"').count - 1).to eq 1
        end

        it 'if the list is not at the top level, adds the options[:ul_class_children] classes to the list of classes' do
          result = helper.arranged_tree_as_list(arranged_tree, { ul_class_children: ['ima', 'kid'] }, &block_to_generate_content)
          expect(result.split('<ul class="ima kid"').count - 1).to eq 3
        end
      end

      it 'creates a list element (li) for every entry ( = top elements (keys) and their descendant)' do
        expect(expected_result_with_default_options.split('<li').count - 1).to eq 5
      end


      describe 'list item (li) classes' do

        it 'adds the options[:li_classes] to the classes for the list element (usually a li element)' do
          result = helper.arranged_tree_as_list(arranged_tree, { li_class: ['this', 'that'] }, &block_to_generate_content)
          expect(result.gsub(ID_STR_PATTERN, BLOTTED_OUT_ID_STR)).to eq expected_result_with_default_options.gsub(/<li([^>]*)class="">/, '<li\1class="this that">')
        end

        it 'if the list element is at the top level, adds the options[:li_class_top] classes to the list of classes' do
          result = helper.arranged_tree_as_list(arranged_tree, { li_class_top: ['li-tippy', 'top'] }, &block_to_generate_content)
          expect(result.split(/class="li-tippy top"/).count - 1).to eq 2
        end

        it 'if the list element is not at the top level, adds the options[:li_class_children] classes to the list of classes' do
          result = helper.arranged_tree_as_list(arranged_tree, { li_class_children: ['li-ima', 'kid'] }, &block_to_generate_content)
          expect(result.split(/class="li-ima kid"/).count - 1).to eq 3
        end
      end
    end

  end


  describe 'list_entry_css_classes' do

    it 'adds "is-list" to the list of classes if the list_entry has children' do
      expect(helper.list_entry_css_classes(create(:master_checklist, num_children: 1))).to include('is-list')
      expect(helper.list_entry_css_classes(create(:master_checklist, num_children: 0))).not_to include('is-list')
    end

    it 'adds "top-level-list" to the list of classes if the list_entry has no ancestors' do
      expect(helper.list_entry_css_classes(create(:master_checklist))).to include('top-level-list')

      parent = create(:master_checklist)
      expect(helper.list_entry_css_classes(create(:master_checklist, parent: parent))).not_to include('top-level-list')
    end
  end

end
