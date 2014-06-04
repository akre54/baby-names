var path = require('path'),
    webpack = require('webpack');

module.exports = {
  cache: true,
  debug: true,
  watch: true,
  devtool: 'source-map',
  entry: {
    'parfait': './app/js/parfait',
    'bar': './app/js/bar'
  },
  output: {
    path: path.join(__dirname, 'public'),
    publicPath: 'public/',
    filename: '[name].js',
    chunkFilename: '[chunkhash].js'
  },
  module: {
    loaders: [
      // required to write 'require('./style.css')'
      { test: /\.css$/,    loader: 'style!css' },
      { test: /\.coffee$/, loader: 'coffee' },

      // Import csv as a file
      { test: /\.csv$/,    loader: 'raw' },

      // Load PNGs
      { test: /\.png$/,    loader: 'url-loader?mimetype=image/png' },

      // required for bootstrap icons
      { test: /\.woff$/,   loader: 'url-loader?prefix=font/&limit=5000&mimetype=application/font-woff' },
      { test: /\.ttf$/,    loader: 'file-loader?prefix=font/' },
      { test: /\.eot$/,    loader: 'file-loader?prefix=font/' },
      { test: /\.svg$/,    loader: 'file-loader?prefix=font/' },
    ],
    noParse: /\.min\.js/
  },
  resolve: {
    modulesDirectories: ['bower_components', 'node_modules'],
    extensions: ['', '.coffee', '.js']
  },
  plugins: [
    new webpack.ResolverPlugin(
      new webpack.ResolverPlugin.DirectoryDescriptionFilePlugin('bower.json', ['main'])
    )
  ]
};
