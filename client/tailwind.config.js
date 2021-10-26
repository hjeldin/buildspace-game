module.exports = {
  purge: [
    './index.html', './src/**/*.{vue,js,ts,jsx,tsx}',
    './node_modules/vue-tailwind-modal/src/VueTailwindModal.vue',
  ],
  darkMode: 'media', // or 'media' or 'class'
  theme: {
    extend: {
      colors: {
				"smoke-900": "rgba(0, 0, 0, 0.9)",
				"smoke-800": "rgba(0, 0, 0, 0.75)",
				"smoke-600": "rgba(0, 0, 0, 0.6)",
				smoke: "rgba(0, 0, 0, 0.5)",
				"smoke-400": "rgba(0, 0, 0, 0.4)",
				"smoke-200": "rgba(0, 0, 0, 0.25)",
				"smoke-100": "rgba(0, 0, 0, 0.1)",
			},
      animation: {
        tilt: 'tilt 10s infinite linear',
        scale: 'scale 1s linear',
        playerAttack: 'playerAttack 0.75s ease-in-out',
        bossAttack: 'bossAttack 0.75s ease-in-out',
        shake: 'shake 1s cubic-bezier(.36,.07,.19,.97) both'
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
        playerAttack: {
          '0%, 100%': {
            transform: 'translateY(0);'
          },
          '50%': {
            transform: 'translateY(-100%);'
          }
        },
        bossAttack: {
          '0%, 100%': {
            transform: 'translateY(0);'
          },
          '50%': {
            transform: 'translateY(100%);'
          }
        },
        shake: {
          "10%, 90%": {
            transform: "translate3d(-1px, 0, 0)"
          },
          
          "20%, 80%": {
            transform: "translate3d(2px, 0, 0)"
          },
        
          "30%, 50%, 70%": {
            transform: "translate3d(-4px, 0, 0)"
          },
        
          "40%, 60%": {
            transform: "translate3d(4px, 0, 0)"
          }
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
