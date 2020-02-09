module.exports = {
  parser: 'sugarss',
  plugins: {
    'postcss-import': {},
    'postcss-preset-env': {stage: 1},
    'cssnano': {},
    'tailwindcss': {},
    'purgecss': process.env.NODE_ENV === 'production' ? 
      { content: ["../lib/web/templates/**/*.html.eex", "./js/**/*.js", "../lib/web/**/*_view.ex"],
        defaultExtractor: content => content.match(/[A-Za-z0-9-_:/]+/g) || [] } : 
      false
  }
};
