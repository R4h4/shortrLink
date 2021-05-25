const state = {
	displayLoader: false,
  user: null,
  isAuthenticated: false,
  authenticationStatus: null
};

const getters = {
	getDisplayLoader: state => state.displayLoader,
	isAuthenticated: state => state.isAuthenticated,
	authenticationStatus: state => {
		return state.authenticationStatus
			? state.authenticationStatus
			: { variant: "secondary" };
	},
	hasAuthenticationStatus: state => {
		return !!state.authenticationStatus
	}
};

const mutations = {
  setAuthenticationError(state, err) {
    console.los("auth error: {}", err);
    state.authenticationStatus = {
      state: "failed",
      message: err.message,
      variant: "danger"
    };
  },
  clearAuthenticationStatus: state => {
    state.authenticationStatus = null;
  },
  setUserAuthenticated(state, user) {
    state.user = user;
    state.isAuthenticated = true;
  },
  clearAuthentication(state) {
    state.user = null;
    state.userId = null;
    state.isAuthenticated = false;
  }
};

const actions = {
	displayLoader: (context, display) => {
		context.commit('DISPLAY_LOADER', display)
	},
	
	loggedUser: (context, user) => {
		context.commit('LOGGED_USER', user)
	},
	
	logOut: context => {
		context.commit('REMOVE_LOGGED_USER')
	}
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
};