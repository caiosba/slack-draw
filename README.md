Slack Draw - Chrome Extension
=============================================

A Google Chrome extension to draw on Slack and share the drawings with the team.

![Demo](demo.gif?raw=true "Demo")

Check [this short video](http://ca.ios.ba/files/meedan/slackdraw.ogv) to see how it works!

The initial idea was to work just as a proof-of-concept about generating a bitmap from a canvas
element and sharing across the network. Check section "TODO" to see what cool things we can do
to improve this extension even more!

### Installation

1. Save the CRX to computer: https://github.com/caiosba/slackdraw/raw/master/extension/slackdraw.js.crx

2. Open Chrome Extensions: chrome://extensions/

3. Drag and Drop CRX file onto Extensions window

4. The extension will autoupdate via Github but you can click "Update Extensions Now" to force a check/update

Or: You can also install from [Google Chrome App Store](https://chrome.google.com/webstore/detail/slack-draw/koafpkkggpelmnganfmkabbacefhkcgj).

5. Go to the options page of the extension and put your Slack token, which you can get from [here](https://api.slack.com/custom-integrations/legacy-tokens) (click you on the green button "Create token" and you'll get a token like `xoxp-0123456789-12345678`)

5. Reload Slack page

PS: It doesn't work with the Slack app, you need to use the web interface (e.g.: http://*.slack.com)

### TODO

* Add more drawing options, like stroke width and stroke color
* Possibility to edit/annotate existing images
* Choose canvas dimensions
* Port to Firefox

### Credits

Caio SBA <caiosba@gmail.com>
