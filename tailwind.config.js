module.exports = {
  // mode: 'jit',
  purge: [
    './app/views/**/*.html.*',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js'
  ],
  darkMode: false,
  theme: {
    extend: {
      screens: {
        print: {raw: 'print'},
      },
      colors: {
        'orange': '#ffa500',
        'malt': '#991A1E',
        'gold': '#A79055',
        'dark-blue': '#0F3E61',
        'success': '#63ed7a',
        'secondary': "#9db3b8",
        'w3green': "#4CAF50",
        'w3red': "#f44336",
        lime: {
          lightest: '#f1fff1',
          lighter: '#e2ffe2',
          light: '#c9ffc9',
          DEFAULT: '#b8ffb8',
          dark: '#96ff96',
          darker: '#7cff7c',
          darkest: '#49ff49',
        },
        // gray: colors.trueGray,

        green: {
          lighter:'hsla(122, 59%, 64%, 1)',
          light: 'hsla(122, 49%, 54%, 1)',
          DEFAULT: 'hsla(122, 39%, 49%, 1)',
          dark: 'hsla(122, 39%, 39%, 1)',
          darker: 'hsla(122, 39%, 29%, 1)',
        },
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],

  
}
