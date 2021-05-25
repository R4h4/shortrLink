
// Import Modules
const login = () => import('@/modules/Login')
const sign_up = () => import('@/modules/SignUp')
const shorten = () => import('@/modules/Shorten')
const reset_password = () => import('@/modules/ResetPassword')

// Export
export default [

    // Home
    {
      path: '/',
      component: shorten,
      name: 'Shorten',
      meta: { title: "shortrLink | Shorter links for everyone", auth: false }
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
        meta: { auth: false  }
    },
    {
      path: '/sign-up',
      component: sign_up ,
      name: 'signUp',
      meta: { auth: false }
  },
  {
    path: '/reset-password',
    component: reset_password ,
    name: 'resetPassword',
    meta: { auth: false }
},

]