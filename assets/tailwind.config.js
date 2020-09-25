module.exports = {
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
  purge: [
    "../**/*.html.eex",
    "../**/*.html.leex",
    "../**/views/**/*.ex",
    "../**/live/**/*.ex",
    "./js/**/*.js",
  ],
  theme: {
    typography: (theme) => ({
      default: {
        css: {
          color: '#aaa',
          'max-width': 'inherit',
          'h1, h2, h3, h4, h5, h6': {
            color: theme('colors.yellow.600'),
            '&:hover': {
              color: theme('colors.yellow.600'),
            }
          },
          'a': {
            color: 'inherit',
            'text-decoration': 'none'
          }
        },
      },
    }),
  },
  variants: {},
  plugins: [
    require('@tailwindcss/typography')
  ],
}
