var Utility = {

  toggle: function () {
    // Toggles (hide or show) via an anchor element $(this) bound to
    // 'click' event.  The 'href' attribute of the element is the
    // id of the content (table, div, etc.) to be toggled
    //
    // Note that this expects the id to have underscores and not hyphens.
    // This is because I18n.t expects underscores and this function is
    // building the I18n.t string.
    var toggleId = $(this).attr('href');
    var showStr = 'toggle.' + toggleId.replace('#','') + '.show';
    var hideStr = 'toggle.' + toggleId.replace('#','') + '.hide';

    var regex = new RegExp(I18n.t(showStr));

    if (regex.test($(this).text())) {
      $(toggleId).show(600);
      $(this).text($(this).text().replace(I18n.t(showStr),
                                          I18n.t(hideStr)));
    } else {
      $(toggleId).hide(600);
      $(this).text($(this).text().replace(I18n.t(hideStr),
                                          I18n.t(showStr)));
    }
    return(false);
  },


  // Use the I18n locale files to swap the i18n string
  // that ends with .show with the string (entry) that ends with .hide
  // or vice versa.
  // This uses the href attribute as the base of the I18n locale key to look up.
  // It prepends 'toggle' to the href attribute and appends 'show' to the end to get
  // the locale key to use when the element is shown.
  // It appends 'hide' to get the locale key to use when the element is hidden (collapsed).

  // Ex:
  //     href='company_search_form'
  //
  //  will create and use these 2 I18n locale entry keys:
  //     toggle.company_search_form.show
  //     toggle.company_search_form.hide
  //
  toggle_i18n_str: function() {

    var toggleId = $(this).attr('href');
    var showStr = 'toggle.' + toggleId.replace('#','') + '.show';
    var hideStr = 'toggle.' + toggleId.replace('#','') + '.hide';

    $(this).text(replace_text($(this).text(), I18n.t(hideStr), I18n.t(showStr)));

    return(false);
  }
};


// Switches out text1 for text2 or text2 for text1 in this.text().
// If text1 string exists in this.text(), replace it with text2
// else replace text2 with text1.
// Uses RegExp to search in this.text() for text1
//
// @param text1 [String] - text to search for; if found replace it with text2
// @param text2 [String] - replacement text; use it to replace text1 if text1 is found,
//   else replace this with text1
function replace_text(original_text, text1, text2) {

  var regex = new RegExp(text1, 'g'); // replace all occurences with the 'g' (global) flag
  var replaced_text = '';

  if (regex.test(original_text)) {
    replaced_text = original_text.replace(text1, text2);
  } else {
    replaced_text = original_text.replace(text2, text1);
  }

  return(replaced_text);
}
