require 'rails_helper'
include ApplicationHelper


RSpec.describe ShfIconsHelper, type: :helper do

  describe 'for each entry in the list of {method starting names and the icons to use for each}' do

    FA_EDIT = 'edit'
    FA_DESTROY = 'trash'

    METHODS_AND_ICONS_FOR_TESTING = [
        { method_name_start: 'edit', icon: FA_EDIT },
        { method_name_start: 'edit_far', icon: FA_EDIT, fa_style: 'far' },
        { method_name_start: 'destroy', icon: FA_DESTROY, html_options: { style: "color: red;" } },
    ]

    before(:each) do
      allow(helper).to receive(:methods_and_icons).and_return(METHODS_AND_ICONS_FOR_TESTING)
    end

    describe 'defines a helper method the produces the HTML for the icon' do

      it "full method name is '<method name start>_icon'" do
        expect(helper.respond_to?('edit_icon')).to be_truthy
        expect(helper.respond_to?('destroy_icon')).to be_truthy
      end

      it 'uses the icon specified in the entry' do
        expect(helper.edit_icon).to match(/<i(.)*class="(.*) fa-edit(.*)"><\/i>/)
        expect(helper.destroy_icon).to match(/<i(.*)class="(.*) fa-trash(.*)"><\/i>/)
      end


      describe 'uses fa_style: in the entry, else uses FA_STYLE_DEFAULT' do

        it 'defaults to FA_STYLE_DEFAULT' do
          allow(helper).to receive(:methods_and_icons).and_return(METHODS_AND_ICONS_FOR_TESTING)

          edit_icon_html = helper.edit_icon
          expect(edit_icon_html).to match(/<i(.*)class="#{described_class::FA_STYLE_DEFAULT} (.*)"(.*)><\/i>/)
          expect(edit_icon_html).not_to include('class="far" ')
        end

        it "fa_style: 'far' is set for the entry" do
          destroy_icon_html = helper.destroy_icon
          expect(destroy_icon_html).to match(/<i(.*)class="far (.*)"(.*)><\/i>/)
        end
      end


      it 'calls get_fa_icon to then produce the code via FontAwesome icon() method' do
        expect(helper).to receive(:get_fa_icon)
        helper.edit_icon
      end


      describe 'parameters' do


        describe 'fa_style:' do

          it "default is 'fas'" do
            expect(helper.edit_icon).to match(/<i(.*)class="fas (.*)"(.*)><\/i>/)
          end

          it 'can specify the FontAwesome style to use' do
            expect(helper.edit_icon(fa_style: 'far')).to match(/<i(.*)class="far (.*)"(.*)><\/i>/)
          end
        end


        describe 'html_options: are merged in' do

          it 'default is {}' do
            expect(helper.edit_icon).to match(/<i(.*)class="fas (.*)"(.*)><\/i>/)
          end

          describe 'can specify the html options to apply' do

            it 'class: "blorf"' do
              edit_icon_result = helper.edit_icon(html_options: { class: 'blorf' })
              expect(edit_icon_result).to match(/<i(.*)class="(.*)blorf(.*)"(.*)><\/i>/)
            end

            it 'style: "color: #123123;' do
              edit_icon_result = helper.edit_icon(html_options: { style: "color: #123123;" })
              expect(edit_icon_result).to match(/<i(.*)style="(.*)color: #123123;(.*)"(.*)><\/i>/)
            end

            it 'style: .. margin, etc, class: "flurb"' do
              edit_icon_result = helper.edit_icon(html_options: { class: 'flurb', style: "margin: 15px; line-height: 1.5; text-align: center;" })
              expect(edit_icon_result).to match(/<i(.*)style="margin: 15px; line-height: 1.5; text-align: center;"(.*)><\/i>/)
              expect(edit_icon_result).to match(/<i(.*)class="(.*)flurb(.*)"(.*)><\/i>/)
            end

          end


        end


        describe 'text:' do

          it 'default is nil (no text)' do
            expect(helper.edit_icon).to match(/<i(.*)><\/i>/)
          end

          it 'can specify the text to display' do
            expect(helper.edit_icon(text: 'blorfity blorf blorf blorf')).to match(/<i(.*)><\/i>(\s*)blorfity blorf blorf blorf/)
          end
        end
      end
    end


    describe 'defines a helper method that returns the full name of the FontAwesome icon' do

      it "full method name is '<method name start>_fa_icon_name'" do
        expect(helper.respond_to?('edit_fa_icon_name')).to be_truthy
        expect(helper.respond_to?('destroy_fa_icon_name')).to be_truthy
      end

      it 'returns the icon name' do
        expect(helper.edit_fa_icon_name).to eq "fa-#{described_class::FA_EDIT}"
        expect(helper.destroy_fa_icon_name).to eq "fa-#{described_class::FA_DESTROY}"
      end
    end
  end


end


