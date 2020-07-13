// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require popper
//= require bootstrap
//= require i18n/translations
//= require_tree .
//= require Chart.bundle
//= require chartkick
//= require bootstrap-toggle
//= require cookies_eu

$(function() {
    'use strict';

    initSelect2Fields('.search_field');

    // Bind 'show/hide' search form accordion label switch
    $('#company_search_form').click(Utility.toggle_accordion_label);
    $('#application_search_form_toggler').click(Utility.toggle_accordion_label);

    // Bind the click action to the Utility toggle (show/hide) function
    $('#toggle_search_form').click(Utility.toggle);

    // Enable all Bootstrap tooltips and popovers
    $('[data-toggle="tooltip"]').tooltip();
    $('[data-toggle="popover"]').popover();

    // CKeditor initialization
    var ready = function() {
      $.each($('.ckeditor'), function (index, ele) {
        CKEDITOR.replace ($(ele).attr('id'));
      })
    };

    $( '.dropdown-menu a.dropdown-toggle' ).on( 'click', function ( e ) {
        var $el = $( this );
        var $parent = $( this ).offsetParent( ".dropdown-menu" );
        if ( !$( this ).next().hasClass( 'show' ) ) {
            $( this ).parents( '.dropdown-menu' ).first().find( '.show' ).removeClass( "show" );
        }
        var $subMenu = $( this ).next( ".dropdown-menu" );
        $subMenu.toggleClass( 'show' );

        $( this ).parent( "li" ).toggleClass( 'show' );

        $( this ).parents( 'li.nav-item.dropdown.show' ).on( 'hidden.bs.dropdown', function ( e ) {
            $( '.dropdown-menu .show' ).removeClass( "show" );
        } );

         if ( !$parent.parent().hasClass( 'navbar-nav' ) ) {
            $el.next().css( { "top": $el[0].offsetTop, "left": $parent.outerWidth() - 4 } );
        }

        return false;
    } );
} );

function initSelect2Fields(selector) {
  // selection string includes class ('.') or ID ('#') designator

  $.each($(selector), function (index, ele) {
    if ($(ele).data('select2') === undefined &&
        $(ele).next().hasClass('select2-container')) {
      $(ele).next().remove();
    }
    $(ele).select2({
      language: $(ele).data('language')
    });
  });
  // Above logic due to problem with using back arrow in browser - see:
  // http://stackoverflow.com/questions/36497723/
  // select2-with-ajax-gets-initialized-several-times-with-rails-turbolinks-events
}
