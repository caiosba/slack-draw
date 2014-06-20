function saveOptions() {
  var token = document.getElementById('token').value;
  chrome.storage.sync.set({'SlackDraw.token': token}, function() {
    alert('Options saved.');
  });
}

function loadOptions() {
  chrome.storage.sync.get({'SlackDraw.token': ''}, function(token) {
    document.getElementById('token').value = token['SlackDraw.token'];
  })
}

document.addEventListener('DOMContentLoaded', loadOptions);
document.getElementById('save').addEventListener('click', saveOptions);
