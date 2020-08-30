const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const OptimizeCSSAssetsPlugin = require('optimize-css-assets-webpack-plugin');
const CopyWebpackPlugin = require('copy-webpack-plugin');
// const PurgecssPlugin = require('purgecss-webpack-plugin');
// const globAll = require('glob-all');
//
// // Custom PurgeCSS extractor for Tailwind that allows special characters in class names.
// // Regex explanation: https://tailwindcss.com/docs/controlling-file-size/#understanding-the-regex
// const TailwindExtractor = content => {
//   return content.match(/[\w-/:]+(?<!:)/g) || [];
// };

module.exports = (env, options) => ({
  optimization: {
    minimizer: [
      new UglifyJsPlugin({ cache: true, parallel: true, sourceMap: false }),
      new OptimizeCSSAssetsPlugin({})
      // new PurgecssPlugin({
      //   paths: globAll.sync([
      //     '../lib/web/templates/**/*.html.eex',
      //     '../lib/web/vies/**/*.ex',
      //     '../assets/js/**/*.js'
      //   ]),
      //   extractors: [
      //     { extractor: TailwindExtractor, extensions: ['html', 'js', 'eex', 'ex'] }
      //   ]
      // })
    ]
  },
  entry: {
      './js/app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js'))
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        exclude: /node_modules/,
        use: {
          loader: 'babel-loader'
        }
      },
      {
        test: /\.[s]?css$/,
        use: [
          MiniCssExtractPlugin.loader,
          'css-loader',
          'postcss-loader',
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({ filename: '../css/app.css' }),
    new CopyWebpackPlugin([{ from: 'static/', to: '../' }])
  ]
});
