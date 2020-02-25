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

  toggle_accordion_label: function () {
    // Changes the label of a bootstrap accordion element based upon whether
    // the element is open or collapsed.
    // The 'id' attribute of the element is the 2nd level i18N lookup key for
    // the associated label (the first level key is 'accordion_label', and the
    // 3rd level key is either 'show' or 'hide'.
    //
    // Note that this expects the id to have underscores and not hyphens.
    // This is because I18n.t expects underscores and this function is
    // building the I18n.t string.
    var toggleId = $(this).attr('id');

    if ($(this).attr('aria-expanded') === 'true') {
      // We are in the process of collapsing the accordion
      var showStr = 'accordion_label.' + toggleId + '.show';
      $(this).text(I18n.t(showStr));
    } else {
      // We are in the process of opening the accordion
      var hideStr = 'accordion_label.' + toggleId + '.hide';
      $(this).text(I18n.t(hideStr));
    }
  },

  httpErrorOccurred: function(response) {
    // Check HTTP error code in jquery response
    // Show alert if error.
    // Return true if error, false otherwise
    if (response.status !== 200 || response.statusText !== 'OK') {
      alert(I18n.t('errors.something_wrong'));
      return true;
    }
    return false;
  },

  actionErrorOccurred: function(response, data) {
    // Check "status" value in response payload.
    // Value should equal a Rails HTTP status code (int or lower-case string)
    // Return true if error, false otherwise
    var action_status;
    if (data !== undefined && data.status !== undefined) {
      action_status = data.status;
    } else {
      action_status = 200;
    }

    if (action_status === 200 || action_status === 'ok') { return false; }

    return true;
  }

};
