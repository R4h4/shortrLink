
// Import Modules
// const login = () => import('@/modules/Login')
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

    // // Login
    // {
    //     path: '/admin/login',
    //     component: login ,
    //     name: 'admin.login',
    //     meta: { guest: true }
    // },

]