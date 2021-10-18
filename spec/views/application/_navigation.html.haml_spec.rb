require 'rails_helper'

RSpec.describe 'Navigation menus' do

  let(:member)  { FactoryBot.create(:member_with_membership_app) }

  let(:admin)   { FactoryBot.create(:user, admin: true) }

  let(:user)    { FactoryBot.create(:user_with_membership_app) }

  let(:cmpy_id) { member.shf_application.companies.first.id }

  let(:cmpy2)   { FactoryBot.create(:company, name: 'Second Company') }

  let(:app_id)  { member.shf_application.id }

  let(:user_app_id) { user.shf_application.id }

  let(:shf_site) { Regexp.escape('https://sverigeshundforetagare.se/') }

  let(:main_site_link_text) { t('menus.nav.shf_main_site') }

  let(:home_text) { t('menus.nav.home') }

  # ----------------------------------------------------------------------------------------------

  shared_examples 'it shows a link to the main site with Hem/Home as the text' do
    it 'Hem/Home link to main site text as a link to it' do
      expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}\">#{home_text}}
    end
  end


  shared_examples "it shows a link to the main site home with SHF main site wording (not 'home/hem')" do
    it 'main site text as a link to it' do
      expect(rendered_html).to match %r{<a class="nav-link" href=\"#{shf_site}\">#{main_site_link_text}}
    end
  end

  shared_examples 'it shows a link to the companies index view' do
    it 'companies index view has a link' do
      text = t('menus.nav.members.shf_companies')
      expect(rendered_html).to match %r{<a class="nav-link" href=\"\/\">#{text}}
    end
  end

  shared_examples 'it has a link to see a list of all publicly viewable companies' do
    it 'link to companies index view' do
      text = t('menus.nav.members.shf_companies')
      expect(rendered).to match %r{<a class="nav-link" href=\"\/\">#{text}}
    end
  end

  shared_examples 'it shows the menu and items for someone logged in' do
    it 'logged-in greeting' do
      expect(rendered).to match %r{#{t('hello', name: member.first_name)}}
    end

    it 'edit-profile link' do
      expect(rendered).to match %r{#{t('devise.registrations.edit.title')}}
    end

    it 'log-off link' do
      expect(rendered).to match %r{#{t('devise.sessions.destroy.log_out')}}
    end
  end

  # ----------------------------------------------------------------------------------------------


  # https://stackoverflow.com/questions/41762057/
  # rails-view-specs-referenced-partials-of-inherited-controllers-arent-found/
  # 41762292#41762292
  before(:each) do
    view.lookup_context.prefixes << 'nav-menus'
    view.lookup_context.prefixes << 'application'
  end

  describe 'member' do

    before(:each) do
      allow(view).to receive(:current_user) { member }
      allow(view).to receive(:user_signed_in?) { true }

      #https://github.com/elabs/pundit/issues/339
      #undefined method `policy' while testing with RSpec views specs
      without_partial_double_verification do
        allow(view).to receive(:policy).and_return(double('ShfApplicationPolicy.new', update?: false))
      end

      assign(:all_displayed_companies, [])
      assign(:search_params, Company.ransack(nil))
      assign(:companies, Company.ransack(nil).result.page(params[:page]).per_page(10))

      render 'nav-menus/navigation'
    end

    it_behaves_like "it shows a link to the main site home with SHF main site wording (not 'home/hem')" do
      let(:rendered_html) { rendered }
    end

    it_behaves_like 'it has a link to see a list of all publicly viewable companies'


    it 'shows link to my application' do
      text = t('menus.nav.users.my_application')
      expect(rendered).to match %r{<a class="nav-link" href=\"\/ansokan\/#{app_id}\">#{text}}
    end

    context 'member pages' do

      it 'shows menu link == member pages index' do
        text = t('menus.nav.members.member_pages')
        expect(rendered).to match %r{href=\'\/medlemssidor\'>(\s*)#{text}}
      end

      it 'shows link to view SHF Board meeting minutes' do
        text = t('menus.nav.members.shf_meeting_minutes')
        expect(rendered).to match %r{<a href=\"\/dokument">#{text}}
      end
    end

    context 'manage my company(s) menu' do

      context 'single company for member' do

        it 'shows menu title == "My Company"' do
          expect(rendered).to match t('my_company', count: 1)
        end

        it 'shows view-company link' do
          text = %r{href="(.*)">(\s*)#{member.companies.first.name}(\s*)<\/a>}
          expect(rendered).to match text
        end
      end

      context 'two companies for member' do

        before(:each) do
          member.shf_application.companies << cmpy2
          member.reload
          render 'nav-menus/navigation'
        end

        # The order the companies are fetched and stored is indeterminate (can vary with each test run)
        # Thus using {cmpy_id} might refer to the first company in one test run, but the second company
        # in another test run -- and thus fail.
        #
        # Explictly defining variables ()with let) this way will get around that problem:
        #
        let(:first_co_name) { member.companies.first.name }
        let(:first_co_id) { member.companies.first.id }
        let(:second_co_name) { member.companies.second.name }
        let(:second_co_id) { member.companies.second.id }


        it 'shows menu title == "My Companies"' do
          expect(rendered).to match t('my_company', count: 2)
        end

        it 'shows view-company link - first company' do
          expect(rendered)
            .to match %r{<a class="nav-link" href=\"\/hundforetag\/#{first_co_id}\">#{first_co_name}}
        end

        it 'shows view-company link - second company' do
          expect(rendered)
            .to match %r{<a class="nav-link" href=\"\/hundforetag\/#{second_co_id}\">(\s*)#{second_co_name}}
        end
      end
    end

    it_behaves_like 'it shows the menu and items for someone logged in'
  end


  describe 'user with application' do

    before(:each) do
      allow(view).to receive(:current_user) { user }
      allow(view).to receive(:user_signed_in?) { true }

      #https://github.com/elabs/pundit/issues/339
      #undefined method `policy' while testing with RSpec views specs
      without_partial_double_verification do
        allow(view).to receive(:policy).and_return(double('ShfApplicationPolicy.new', update?: true))
      end

      assign(:all_displayed_companies, [])
      assign(:search_params, Company.ransack(nil))
      assign(:companies, Company.ransack(nil).result.page(params[:page]).per_page(10))

      render 'nav-menus/navigation'
    end

    it_behaves_like "it shows a link to the main site home with SHF main site wording (not 'home/hem')" do
      let(:rendered_html) { rendered }
    end

    it_behaves_like 'it shows a link to the companies index view' do
      let(:rendered_html) { rendered }
    end

    it_behaves_like 'it has a link to see a list of all publicly viewable companies'


    it 'shows link to edit my application' do
      text = t('menus.nav.users.my_application')
      expect(rendered).to match %r{<a class="nav-link" href=\"\/ansokan\/#{user_app_id}\/redigera\">#{text}}
    end

    it_behaves_like 'it shows the menu and items for someone logged in'
  end


  describe 'admin' do

    before(:each) do
      allow(view).to receive(:current_user) { admin }
      allow(view).to receive(:user_signed_in?) { true }

      render 'nav-menus/navigation'
    end

    context 'member pages' do

      it 'shows menu link == member pages index' do
        text = t('menus.nav.members.member_pages')
        expect(rendered).to match %r{href='\/medlemssidor'>#{text}}
      end

      it 'shows link to view SHF Board meeting minutes' do
        text = t('menus.nav.members.shf_meeting_minutes')
        expect(rendered).to match %r{<a href=\"\/dokument">#{text}}
      end
    end

    it_behaves_like "it shows a link to the main site home with SHF main site wording (not 'home/hem')" do
      let(:rendered_html) { rendered }
    end


    context 'membership applications' do

      it 'shows submenu title' do
        text = t('menus.nav.admin.applications.submenu_title')
        expect(rendered).to match %r{#{text}}
      end

      it 'shows manage-applications link' do
        text = t('menus.nav.admin.applications.manage_applications')
        expect(rendered).to match %r{<a class="nav-link" href=\"\/ansokan\">#{text}}
      end

      it 'shows waiting-reasons link' do
        text = t('menus.nav.admin.applications.waiting_reasons')
        expect(rendered).to match %r{<a class="nav-link" href=\"\/admin\/member_app_waiting_reasons\">#{text}}
      end

    end

    context 'business categories' do

      it 'shows submenu title' do
        text = t('menus.nav.admin.categories.submenu_title')
        expect(rendered).to match %r{#{text}}
      end

      it 'shows categories link' do
        text = t('menus.nav.admin.categories.submenu_title')
        expect(rendered).to match %r{<a class="nav-link" href=\"\/kategori\">#{text}}
      end
    end

    context 'companies' do

      it 'shows submenu title' do
        text = t('menus.nav.admin.companies.submenu_title')
        expect(rendered).to match %r{#{text}}
      end

      it 'shows manage-companies link' do
        text = t('menus.nav.admin.companies.manage_companies')
        expect(rendered).to match %r{<a class="nav-link" href=\"\/hundforetag\">#{text}}
      end

      it 'shows new-company link' do
        text = t('menus.nav.admin.companies.new_company')
        expect(rendered).to match %r{<a class="nav-link" href=\"\/hundforetag\/ny\">#{text}}
      end
    end

    it 'shows link to users index view' do
      text = t('menus.nav.admin.users.list_users')
      expect(rendered).to match %r{<a class="nav-link" href=\"\/anvandare\">#{text}}
    end

    it_behaves_like 'it shows the menu and items for someone logged in'

    context 'logged-in menu' do

      it 'view-your-account link' do
        expect(rendered).to match %r{#{t('menus.nav.users.your_account')}}
      end

      it 'app-configuration link' do
        expect(rendered).to match %r{#{t('menus.nav.admin.app_configuration')}}
      end
    end

  end

  describe 'visitor' do

    before(:each) do
      allow(view).to receive(:current_user) { Visitor.new }

      render 'nav-menus/navigation'
    end

    it_behaves_like 'it shows a link to the main site with Hem/Home as the text' do
      let(:rendered_html) { rendered }
    end

    describe 'association menu' do
      it 'shows association link' do
        text = t('menus.nav.visitor.association')
        expect(rendered).to match %r{href=\"#{shf_site}broschyr\/\">#{text}}
      end

      it 'shows brochure link' do
        text = t('menus.nav.visitor.brochure')
        expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}broschyr\/\">#{text}}
      end

      it 'shows membership link' do
        text = t('menus.nav.visitor.membership')
        expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}foretag/medlemsatagande\/\">#{text}}
      end

      it 'shows board link' do
        text = t('menus.nav.visitor.board')
        expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}styrelse\/\">#{text}}
      end

      it 'shows statues link' do
        text = t('menus.nav.visitor.board_statues')
        expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}stadgar\/\">#{text}}
      end


      it 'shows glossary link' do
        text = t('menus.nav.visitor.glossary')
        expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}ordlista\/\">#{text}}
      end


      it 'shows history link' do
        text = t('menus.nav.visitor.history')
        expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}historik\/\">#{text}}
      end

    end


    context 'for-dog-owners menu' do

      it 'shows about-us link' do
        text = Regexp.escape(t('menus.nav.visitor.dog_owners.about_us'))
        expect(rendered).to match %r{href=\"#{shf_site}agare\/om-sveriges-hundforetagare\/\">#{text}}x
      end

      it 'shows H-Mark link' do
        text = Regexp.escape(t('menus.nav.visitor.dog_owners.h_label'))
        expect(rendered).to match %r{href=\"#{shf_site}agare\/h-markt-av-sveriges-hundforetagare\/\">#{text}}x
      end

      it 'shows consumer contact link' do
        text = Regexp.escape(t('menus.nav.visitor.dog_owners.consumer_contact'))
        expect(rendered).to match %r{href=\"#{shf_site}agare\/konsumentkontakt\/\">#{text}}x
      end

      it 'shows become-a-supporter link' do
        text = t('menus.nav.visitor.dog_owners.become_supporter')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}agare\/bli-stodmedlem\/\">#{text}}
      end

      it 'shows being-dog-owners link' do
        text = t('menus.nav.visitor.find_dog_businesses')
        expect(rendered).to match %r{<a class="nav-link" href=\"\/">#{text}}
      end
    end

    context 'dog-company-owners menu' do

      it 'shows about-us link' do
        text = Regexp.escape(t('menus.nav.visitor.entrepreneurs.about_us'))
        expect(rendered).to match %r{href=\"#{shf_site}foretag\/om-sveriges-hundforetagare\/\">#{text}}
      end

      it 'shows become-H-labeled link' do
        text = t('menus.nav.visitor.entrepreneurs.be_h_labeled')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/bli-h-markt\/\">#{text}}
      end

      it 'shows sign up link' do
        text = t('menus.nav.visitor.entrepreneurs.be_h_labeled')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/bli-h-markt\/\">#{text}}
      end

      it 'shows educational_reqs link' do
        text = t('menus.nav.visitor.entrepreneurs.educational_reqs')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/medlemskriterier\/\">#{text}}
      end


      it 'shows membership_commitment link' do
        text = t('menus.nav.visitor.entrepreneurs.membership_commitment')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/medlemsatagande\/\">#{text}}
      end

      it 'shows ethical_guide link' do
        text = t('menus.nav.visitor.entrepreneurs.ethical_guide')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/lima-guiden\/\">#{text}}
      end

      it 'shows member-standards link' do
        text = t('menus.nav.visitor.entrepreneurs.quality_standards')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/kvalitetskontroll\/\">#{text}}
      end

      it 'shows GDPR link' do
        text = t('menus.nav.visitor.entrepreneurs.gdpr')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/gdpr\/\">#{text}}
      end


      it 'shows to_become_a_dog_business link' do
        text = t('menus.nav.visitor.entrepreneurs.to_become_a_dog_business')
        expect(rendered)
          .to match %r{<a class="nav-link" href=\"#{shf_site}foretag\/vill-du-bli-hundforetagare\/\">#{text}}
      end
    end


    it 'shows contact link' do
      text = t('menus.nav.visitor.contact')
      expect(rendered).to match %r{<a class="nav-link" href=\"#{shf_site}kontakt\/\">#{text}}
    end

    it 'shows log-in link' do
      text = t('devise.sessions.new.log_in')
      expect(rendered).to match %r{<a .* href=\"\/users\/sign_in">#{text}}
    end
  end
end
