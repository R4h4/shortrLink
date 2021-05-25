import { createStore } from 'vuex'
import createPersist from "vuex-localstorage";

// Modules
import auth from "./modules/auth";

export default createStore({
  modules: {
    auth
  },
//  strict: debug,
  plugins: [
    createPersist({
      namespace: "shortrlink",
      initialState: {},
      // ONE_WEEK
      expires: 7 * 24 * 60 * 60 * 1e3
    })
  ]
});
