$(document).ready(function() {
  
  $('#tweets_add_more').click(function() {
    $('#tweet_fields').append("<fieldset><p><textarea name='tweets[]' placeholder='Enter your tweet...'></textarea><br /><a href='javascript:void();' onclick='$(this).parent().parent().remove(); return false;'>[Cancel]</a></p></fieldset>");
    $('#tweet_fields fieldset:last-child textarea').focus();
    return false;
  }).removeClass('hide');

});