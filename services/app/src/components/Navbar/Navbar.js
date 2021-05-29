import store from '@/store'
import shortrLink from '@/components/LinkShortener'

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
  components: {
    shortrLink
  },
  methods: {
  }
}