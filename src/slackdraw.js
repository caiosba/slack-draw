$(function() {

  // Opens the modal with the canvas
  var openModal = function() {
    var html = '<canvas id="slack_draw_sketch" width="550" height="295"></canvas>';
    html +=    '<p id="slack_draw_footer">';
    html +=    '  <input id="slack_draw_title" placeholder="Title" />';
    html +=    '  <input id="slack_draw_comment" placeholder="Comment" />';
    html +=    '  <a href="#" id="slack_draw_share">Share</a>';
    html +=    '</p>';
    $.modal(html);
    $('#slack_draw_sketch').sketch();
    $('#slack_draw_share').click(function() {
      if (confirm('Are you sure you want to share this drawing? It will be available to all users on this channel.')) {
        shareDraw();
      }
      return false;
    });
  };

  // Get the active conversation
  var getCurrentConversation = function() {
    var $channel = $('#channel-list .active'),
        $member  = $('#im-list .active');
    if ($channel.length) {
      return $channel.attr('class').replace(/.*channel_([^ ]+).*/, '$1');
    }
    else if ($member.length) {
      return $member.attr('class').replace(/.*member_([^ ]+).*/, '$1');
    }
    return null;
  };

  // Share the drawing
  var shareDraw = function() {
    chrome.storage.sync.get({'SlackDraw.token': ''}, function(data) {
      var token   = data['SlackDraw.token'],
          title   = $('#slack_draw_title').val(),
          comment = $('#slack_draw_comment').val(),
          channel = getCurrentConversation(),
          canvas  = $('#slack_draw_sketch')[0];

      if (canvas.toBlob) {
        canvas.toBlob(function(blob) {
          var formdata = new FormData();
          formdata.append('token', token);
          formdata.append('file', blob);
          formdata.append('title', title);
          formdata.append('initial_comment', comment);
          formdata.append('channels', channel);
          $.ajax({
            url: 'https://slack.com/api/files.upload',
            type: 'POST',
            data: formdata,
            processData: false,
            contentType: false,
          }).done(function(response){
            if (!response || !response.ok) {
              alert('Could not upload your drawing!');
            }
            $.modal.close();
          });
        }, 'image/png');
      }
    });
  };

  // Watch when the upload menu is displayed
  $(document).bind('DOMNodeInserted', function(e) {
    var $element = $(e.target);
    if ($element.is('#menu')) {
      
      // Create a new item for the upload menu
      var $item = $('<li data-which="draw" class="file_menu_item" id="slack_draw_item"></li>'),
          $link = $('<a target="_blank" href="#" id="slack_draw_link"></a>').html('<i class="file_menu_icon draw"></i> Create a drawing');
      $item.append($link);
      $('#menu_items').append($item);
      $link.click(function() {
        openModal();
        return false;
      });

    }
  });
});
