
// Import Modules
const dashboard = () => import('@/modules/Dashboard')
// import UserInfoStore from '@/store/user-info-store';
// import UserInfoApi from '@/utils/user-info-api';

// function requireAuth(to, from, next) {
//   if (!app.$cognitoAuth.isAuthenticated()) {
//       UserInfoStore.setLoggedIn(false);
//       next({
//       path: '/login',
//       query: { redirect: to.fullPath }
//       });
//   } else {
//     UserInfoApi.getUserInfo().then(response => {
//       UserInfoStore.setLoggedIn(true);
//       UserInfoStore.setCognitoInfo(response);
//       next();
//     });
      
//   }
// }

// Export
export default [
    // Home
    {
      path: '/dashboard',
      component: dashboard,
      name: 'Dashboard',
      // beforeEnter: requireAuth,
      meta: {title: 'shortrLink Dashboard', auth: true}
    },

]