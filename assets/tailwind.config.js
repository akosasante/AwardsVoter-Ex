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
    container: {
      padding: "2rem"
    },
    fontSize: {
      xs: ".75rem",
      sm: ".875rem",
      tiny: ".875rem",
      base: "1rem",
      lg: "1.125rem",
      xl: "1.25rem",
      "2xl": "1.5rem",
      "3xl": "1.875rem",
      "4xl": "2.25rem",
      "5xl": "3rem",
      "6xl": "4rem",
      "7xl": "5rem",
      "8xl": "6rem",
      "9xl": "7rem",
      "10xl": "8rem"
    },
    extend: {
      spacing: {
        "72": "18rem",
        "84": "21rem",
        "96": "24rem"
      },
      maxWidth: {
        "1/4": "25%",
        "1/2": "50%",
        "3/4": "75%",
        "9/10": "90%"
      },
      translate: {
        double: "200%",
        triple: "300%",
        quad: "400%"
      },
      height: {
        "2px": "2px"
      },
      inset: {
        "24": "5rem", // not for real
        "1/2": "50%",
        full: "100%"
      },
      transitionProperty: {
        width: "width"
      },
      fontFamily: {
        'title': ['Limelight', 'ui-sans-serif', 'system-ui']
      },
      zIndex: {
          '-1': '-1'
      }
    }
  },
  variants: {},
  plugins: [
    require('@tailwindcss/typography'),
    require('@tailwindcss/forms')
  ],
}
