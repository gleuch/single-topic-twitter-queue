/*
  Single Topic Twitter Queue
  Built by Greg Leuch <http://gleu.ch>
  ------------------------------------------------------------
  http://github.com/gleuch/single-topic-twitter-queue
  Released under GNU General Public License.
  
*/


$(document).ready(function() {

  $('time').timeago();

  $('#tweets_add_more').click(function() {
    $('#tweet_fields').append("<fieldset><p><textarea class='tweet' name='tweets[]' placeholder='Enter your tweet...'></textarea></p><aside class='c'><button class='cancel hide right'>Cancel</button><p class='right charsleft hide'>140</p></aside></fieldset>");
    $('#tweet_fields fieldset:last-child').hide().fadeIn(250);
    $('#tweet_fields fieldset:last-child textarea').change(dFx.charLimit).keyup(dFx.charLimit).focusin(dFx.charLimit).focusout(dFx.charLimit).focus();
    $('#tweet_fields fieldset:last-child button.cancel').removeClass('hide');
    return false;
  }).removeClass('hide');


  $('details li.send').click(function() {
    var url = $(this).find('a').attr('href'), fs = $(this).parent().parent().parent();

    $.ajax({
      url:      url,
      type:     'POST',
      context:  fs,
      success:  function() {$(this).removeClass('highlight'); dFx.success(this);},
      error:    function(r, t, e) {dFx.error(this);}
    });
    return false;
  }).removeClass('hide');

  $('details li.delete').click(function() {
    var url = $(this).find('a').attr('href'), fs = $(this).parent().parent().parent();

    $(fs).addClass('highlight');
    var del = confirm('Are you sure you want to delete this tweet?');
    $(fs).removeClass('highlight');

    if (!del) return false;
    

    $.ajax({
      url:      url,
      type:     'POST',
      context:  fs,
      success:  function() {dFx.success(this);},
      error:    function(r, t, e) {dFx.error(this);}
    });
    return false;
  }).removeClass('hide');

  $('.cancel').live('click', function(){
    var obj = $(this).parent().parent();
    $(obj).animate({'height':0}, {duration: 100, queue: true, complete: function() {$(obj).html('').remove();}});
    return false;
  }).removeClass('hide');
  
  
  $('textarea.tweet').change(dFx.charLimit).keyup(dFx.charLimit).focusin(dFx.charLimit).focusout(dFx.charLimit);
  $('.charsleft').removeClass('hide');
});






var dFx = {
  charLimit : function() {
    var charsLeft = 140 - $(this).val().strip().length;
    /* TODO : Make shades of red when close to 0 */
    $(this).parent().parent().find('.charsleft').removeClass('hide').html(charsLeft);
  },

  success : function(obj) {
    for (var i=0; i<3; i++) {
      $(obj).animate({'opacity':.25}, {duration: 100, queue: true});
      $(obj).animate({'opacity':1}, {duration: 100, queue: true});
    }
    $(obj).animate({'height':0}, {duration: 100, queue: true, complete: function() {$(obj).html('').remove();}});
  },
  
  error : function(obj) {
    $(obj).animate({'margin-left': '-10px', 'margin-right': '10px'}, {duration : 50, queue : true});
    for (var i=0; i<3; i++) {
      $(obj).animate({'margin-left': '10px', 'margin-right': '-10px'}, {duration : 100, queue : true});
      $(obj).animate({'margin-left': '-10px', 'margin-right': '10px'}, {duration : 100, queue : true});
    }
    $(obj).animate({'margin-left': '0px', 'margin-right': '0px'}, {duration : 50, queue : true});    
  }
}

String.prototype.strip = function() {return this.replace(/^([\n\r\s ]+)/, '').replace(/([\n\r\s ]+)$/, '');};