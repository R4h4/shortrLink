// Import
import { createWebHistory, createRouter } from 'vue-router'
import publicRoutes from './PublicRoutes.js'
import privateRoutes from './PrivateRoutes.js'
import store from '@/store'

// Start vue router
const router = createRouter({
    history: createWebHistory(),
    routes: [...publicRoutes, ...privateRoutes]
})

// this routine will ensure that any pages marked as `auth` in the `meta` section are
// protected from access by unauthenticated users.
router.beforeEach((to, from, next) => {
    // Use the page's router title to name the page
    if (to.meta && to.meta.title) {
      document.title = to.meta.title;
    }
  
    // is there a meta and auth attribute?
    if (to.meta && to.meta.auth !== undefined) {
      // if the page requires auth
      if (to.meta.auth) {
        // and we are authenticated?
        if (store.getters["auth/isAuthenticated"]) {
          next(); // route normally
          return;
        }
        // otherwise off to the sign in page
        router.push({ name: "signIn" });
        return;
      }
      // otherwise are we already authenticated?
      if (store.getters["auth/isAuthenticated"]) {
        // yes we are, so off to dashboard
        router.push({ name: "dashboard" });
        return;
      }
      next(); // route normally
      return;
    }
    next(); // route normally
    return;
  });

// Export
export default router