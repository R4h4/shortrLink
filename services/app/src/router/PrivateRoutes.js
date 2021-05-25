
// Import Modules
const dashboard = () => import('@/modules/Dashboard')
const signout = () => import('@/modules/SignOut')
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
    name: 'dashboard',
    // beforeEnter: requireAuth,
    meta: { title: 'shortrLink Dashboard', auth: true }
  },
  {
    path: '/sign-out',
    component: signout,
    name: 'signOut',
    meta: { title: 'shortrLink | Logging out', auth: true }
  }
]