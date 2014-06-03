#!/usr/bin/env node

var webpack = require('webpack'),
    webpackConfig = require('./webpack.config'),
    fs = require('fs'),
    mkdirp = require('mkdirp'),
    rimraf = require('rimraf');

var cp = function(filename, destFolder) {
  fs.createReadStream('./app/' + filename).pipe(fs.createWriteStream(destFolder + filename));
}

rimraf('./public', function() {
  mkdirp('./public', function() {
    cp('index.html', './public/');
    cp('parfait.html', './public/');
    webpack(webpackConfig, function(err, stats) {
      console.log(stats.toString());
    });
  });
});

