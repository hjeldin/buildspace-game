module.exports = {
  purge: [
    './index.html', './src/**/*.{vue,js,ts,jsx,tsx}'
  ],
  darkMode: 'media', // or 'media' or 'class'
  theme: {
    extend: {
      animation: {
        tilt: 'tilt 10s infinite linear',
        scale: 'scale 1s linear'
      },
      keyframes: {
        tilt: {
          '0%, 50%, 100%': {
            transform: 'rotate(0deg)',
          },
          '25%': {
            transform: 'rotate(0.5deg)',
          },
          '75%': {
            transform: 'rotate(-0.5deg)',
          },
        },
        scale: {
          '0%, 100%': {transform: 'scale(100%)'},
          '50%': {transform: 'scale(110%)'}
        }
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
