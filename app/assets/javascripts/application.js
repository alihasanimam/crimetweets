// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require twitter/bootstrap
//= require chosen-jquery
//= require underscore
//= require gmaps/google
//= require nprogress
//= require nprogress-turbolinks
//= require turbolinks
////= require_tree .

$(document).ready(function(){
    // enable chosen js
    $('.chosen-select-1').chosen({
        allow_single_deselect: true,
        max_selected_options: 7,
        no_results_text: 'No results matched',
        width: '100%'
    });
    $('.chosen-select-2').chosen({
        allow_single_deselect: true,
        max_selected_options: 3,
        no_results_text: 'No results matched',
        width: '100%'
    });
});

$(document).on('page:fetch', function() {
    return $('#content').animate({marginLeft: '-150%'}, 'slow');
});

$(document).on('page:change', function() {
//    return $('#content').css({marginLeft: '100%'}).animate({marginLeft: '0%'}, 'fast');
    return $('#content').hide().fadeIn('slow');
});