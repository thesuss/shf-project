require 'rails_helper'

RSpec.describe NavMenusHelper, type: :helper do

  describe 'nav_menu_dropdown_li' do

    describe ' default values' do
      let(:all_defaults_result) { helper.nav_menu_dropdown_li }

      it 'link_to text is empty' do
        expect(all_defaults_result).to match(/<a(.*)><\/a>/)
      end

      it 'link is #' do
        expect(all_defaults_result).to match(/<a(.*)href="#">/)
      end

      it "link classes == ['dropdown-toggle nav-link']" do
        expect(all_defaults_result).to match(/<a(.*)class="dropdown-toggle nav-link"(.*)>/)
      end

      it 'link options are "aria-expanded" => "false", "aria-haspopup" => "true", "data-toggle" => "dropdown"' do
        expect(all_defaults_result).to match(/<a(.*)aria-expanded="false"(.*)>/)
        expect(all_defaults_result).to match(/<a(.*)aria-haspopup="true"(.*)>/)
        expect(all_defaults_result).to match(/<a(.*)data-toggle="dropdown"(.*)>/)
      end

      it 'li classes is "dropdown"' do
        expect(all_defaults_result).to match(/<li(.*)class="dropdown"(.*)>/)
      end
    end


    context 'a block is passed in' do
      it 'calls the block (yield) so nested HTML can be produced' do

        expect(helper).to receive(:nav_menu_item_li)
        helper.nav_menu_dropdown_li(text: 'this is the text', link: 'this-is-the-link') do
          helper.nav_menu_item_li(text: 'sub-item')
        end
      end
    end


    it 'also creates any html from a given block' do

      expect(helper).to receive(:nav_menu_item_li)
                          .with(text: 'this is the inner text', link: 'this-is-the-inner-link')
      helper.nav_menu_dropdown_li(text: 'this is the text', link: 'this-is-the-link') do
        helper.nav_menu_item_li(text: 'this is the inner text', link: 'this-is-the-inner-link',)
      end
    end
  end


  describe 'nav_menu_item_li' do

    describe ' default values' do
      let(:all_defaults_result) { helper.nav_menu_item_li }

      it 'link_to text is empty' do
        expect(all_defaults_result).to match(/<a(.*)><\/a>/)
      end

      it 'link is #' do
        expect(all_defaults_result).to match(/<a(.*)href="#">/)
      end

      it "link classes == ['nav-link']" do
        expect(all_defaults_result).to match(/<a class="nav-link"(.*)>/)
      end

      it "link options is empty" do
        expect(all_defaults_result).to match(/<a class="(.*)" href="(.*)>/)
      end

      it 'li classes is empty' do
        expect(all_defaults_result).to match(/<li class=""(.*)>/)
      end
    end


    describe 'creates HTML for a "li <a href=[link]>link text</a>"' do

      it 'sets link text' do
        expect(helper.nav_menu_item_li(text:'this is the text')).to match(/<a (.*)>this is the text<\/a>/)
      end

      it 'li classes' do
        expect(helper.nav_menu_item_li(text:'this is the text', li_classes: ['li1', 'li2'])).to match(/<li class="li1 li2"(.*)>/)
      end

      it 'link classes are merged with the default link classes' do
        expect(helper.nav_menu_item_li(text:'this is the text', link_classes: ['link1', 'link2'])).to match(/<a class="link1 link2 nav-link"(.*)>/)
        expect(helper.nav_menu_item_li(text:'this is the text', link_classes: ['link1', 'nav-link'])).to match(/<a class="link1 nav-link"(.*)>/)
      end

      it 'accepts any other options for the link' do
        expect(helper.nav_menu_item_li(text:'this is the text', link_options: { method: :delete}))
          .to match(/<a(.*)data-method="delete"(.*)>/)
        expect(helper.nav_menu_item_li(text:'this is the text', link_classes: ['another-class'],
                                       link_options: {method: :delete}))
          .to match(/.*<a.*class="another-class nav-link"(.*)data-method="delete"(.*)>/)
      end
    end

  end

end
