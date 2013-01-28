// My SocketStream 0.3 app

var http = require('http'),
    ss = require('socketstream');

// Define a single-page client called 'main'
ss.client.define('main', {
  view: 'app.jade',
  css:  ['app.styl'],
  code: ['libs/jquery.min.js', 'libs/kinetic.js', 'app'],
  tmpl: '*'
});

// Define a single-page client called 'main'
ss.client.define('scores', {
  view: 'scores.jade',
  css:  ['app.styl', 'simple.datagrid.css'],
  code: ['libs/jquery.min.js', 'libs/simple.datagrid.js', 'scores'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('main');
});

// Serve this client on the /scores/ URL
ss.http.route('/scores/', function(req, res){
  res.serveClient('scores');
});

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env === 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(3000);

// Start SocketStream
ss.start(server);