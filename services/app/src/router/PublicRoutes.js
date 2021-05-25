
// Import Modules
const sign_in = () => import('@/modules/SignIn')
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
    meta: { title: "shortrLink | Shorter links for everyone" }
  },
  {
      path: '/login',
      component: sign_in ,
      name: 'signIn',
      meta: { title: 'shortrLink | Login', auth: false }
  },
  {
    path: '/sign-up',
    component: sign_up ,
    name: 'signUp',
    meta: { title: 'shortrLink | Sign Up', auth: false }
  },
  {
    path: '/reset-password',
    component: reset_password ,
    name: 'resetPassword',
    meta: { title: 'shortrLink | Reset Password', auth: false }
  }
]