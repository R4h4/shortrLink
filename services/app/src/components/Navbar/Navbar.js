import store from '@/store'

export default {
  name: 'Navbar',
  data() {
      return {
      }
  },
  computed: {
    isAuthenticated() {
      return store.getters['auth/isAuthenticated']
    }
  },
  methods: {
  }
}