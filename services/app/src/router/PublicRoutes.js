
// Import Modules
const login = () => import('@/modules/Login')
const sign_up = () => import('@/modules/SignUp')
const shorten = () => import('@/modules/Shorten')

// Export
export default [

    // Home
    {
      path: '/',
      component: shorten,
      name: 'Shorten'
    },

    // // Home
    // {
    //     path: '/',
    //     redirect: '/admin/dashboard' 
    // },

    // Login
    {
        path: '/login',
        component: login ,
        name: 'login',
        meta: { guest: true }
    },
    {
      path: '/sign-up',
      component: sign_up ,
      name: 'signUp',
      meta: { guest: true }
  },

]