# frozen_string_literal: true

require 'rails_helper'

describe InputSanitizer do
  context 'URL sanitizer' do
    it 'handles nil' do
      expect(InputSanitizer.sanitize_url(nil)).to eq ''
    end

    it 'removes javascript' do
      expect(InputSanitizer.sanitize_url('blorfo///"javascript//"')).to eq 'blorfo///"//"'
    end

    it 'uses Sanitizer to remove CSS tags' do
      expect(InputSanitizer.sanitize_url('<STYLE>@import"alert(\'XSS\')";</STYLE>')).to eq ''
    end

    it 'uses Santizer to remove anything inside a tag' do
      expect(InputSanitizer.sanitize_url('<IMG SRC="javascript:alert(\'XSS\');">')).to eq ''
    end

    it 'uses remove tags and javascript' do
      expect(InputSanitizer.sanitize_url('<STYLE>@import"javascript:alert(\'XSS\')";</STYLE>')).to eq ''
    end
  end

  context 'HTML Sanitizer' do
    it 'handles nil and empty string' do
      expect(InputSanitizer.sanitize_html(nil)).to eq ''
      expect(InputSanitizer.sanitize_html('')).to eq ''
    end

    it 'removes script tags' do
      expect(InputSanitizer.sanitize_html("<script>alert('Hello');</script>"))
          .to eq ''

      expect(InputSanitizer.sanitize_html("<SCRIPT>alert('Hello');</SCRIPT>"))
          .to eq ''

      expect(InputSanitizer.sanitize_html("<scscriptript>alert('Hello');</scscriptript>"))
          .to eq "alert('Hello');"
    end

    it 'removes javascript' do
      str = "<img src=javascript:alert('Hello')>"
      expect(InputSanitizer.sanitize_html(str)).to eq '<img>'

      str = %{<table background="javascript:alert('Hello')">}
      expect(InputSanitizer.sanitize_html(str)).to eq '<table></table>'
    end

    it 'removes other unwanted tags' do
      str = '<button>Please click me</button>'
      expect(InputSanitizer.sanitize_html(str)).to eq 'Please click me'

      str = '<canvas> ... </canvas>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '

      str = '<embed> ... </embed>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '

      str = '<html> ... </html>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '

      str = '<input> ... </input>'
      expect(InputSanitizer.sanitize_html(str)).to eq ' ... '
    end

    it 'removes iframe' do
      str = '<iframe src="www.othersite.com"></iframe>'
      expect(InputSanitizer.sanitize_html(str)).to be_empty
    end

    it 'removes event handlers' do
      str = '<img src="http://www.harmless.com/img" width="400" ' \
            'height="400" onmouseover="..." />'
      expect(InputSanitizer.sanitize_html(str))
          .to eq '<img src="http://www.harmless.com/img" width="400" height="400">'

      str = '<button onclick="...">Please click me</button>'
      expect(InputSanitizer.sanitize_html(str)).to eq 'Please click me'
    end
  end

  context '.sanitize_string String sanitizer' do

    it 'returns empty string if input is nil' do
      expect(InputSanitizer.sanitize_string(nil))
          .to eq ''
    end

    it 'returns empty string if input is an empty string' do
      expect(InputSanitizer.sanitize_string(''))
          .to eq ''
    end

    it 'returns text if no tags' do
      expect(InputSanitizer.sanitize_string('just text'))
          .to eq 'just text'
    end


    context 'unsafe tags and their contents removed' do

      it 'returns just plain text outside of tags' do
        expect(InputSanitizer.sanitize_string("start of plain text<javascript>alert('Hello');</javascript>plain text"))
            .to eq 'start of plain textplain text'
      end

      it 'script' do
        expect(InputSanitizer.sanitize_string("<script>alert('Hello');</script>"))
            .to eq ''
        expect(InputSanitizer.sanitize_string("<javascript>alert('Hello');</javascript>"))
            .to eq ''

        str = "<img src=javascript:alert('Hello')>"
        expect(InputSanitizer.sanitize_string(str)).to eq ''

        str = %{<table background="javascript:alert('Hello')">}
        expect(InputSanitizer.sanitize_string(str)).to eq ''

        expect(InputSanitizer.sanitize_string("<script>alert('Hello');</script>"))
            .to eq ''

        expect(InputSanitizer.sanitize_string("<SCRIPT>alert('Hello');</SCRIPT>"))
            .to eq ''

        expect(InputSanitizer.sanitize_string("<scscriptript>alert('Hello');</scscriptript>"))
            .to eq ''
      end

    end # context unsafe tags

    context 'style tags and their contents removed' do

      it 'style tag and contents removed' do
        expect(InputSanitizer.sanitize_string("ohai! <style='margin: 10px'>styled text</style>"))
        .to eq 'ohai! '
      end

      it 'element with style is removed, plain text stays' do
        expect(InputSanitizer.sanitize_string("ohai! <div id='foo' class='bar' style='margin: 10px'>div text remains</div>"))
            .to eq 'ohai! div text remains'
      end
    end #context style tags

    context 'safe tags: text within is returned' do

      it 'canvas' do
        str = '<canvas> text within tags</canvas>'
        expect(InputSanitizer.sanitize_string(str)).to eq ' text within tags'
      end

      it 'other tags' do
        str = '<button>Please click me</button>'
        expect(InputSanitizer.sanitize_string(str)).to eq 'Please click me'

        str = '<embed> ... </embed>'
        expect(InputSanitizer.sanitize_string(str)).to eq ''

        str = '<html> inside tags </html>'
        expect(InputSanitizer.sanitize_string(str)).to eq ' inside tags '

        str = '<input> inside tags </input>'
        expect(InputSanitizer.sanitize_string(str)).to eq ' inside tags '
      end

      it 'iframe' do
        str = '<iframe src="www.othersite.com"></iframe>'
        expect(InputSanitizer.sanitize_string(str)).to eq ''
      end

      it 'removes nested tags' do
        str = '<html>this html<div> this div <button> inside button text</button> end div </div> end html</html>'
        expect(InputSanitizer.sanitize_string(str))
            .to eq 'this html this div  inside button text end div  end html'

      end

    end # context safe tags

  end

end
