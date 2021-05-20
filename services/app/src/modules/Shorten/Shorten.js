import mainLayout from '@/layouts/Main'
import shortrLink from '@/components/LinkShortener'
// import httpAxios from '@/utils/http-axios'

export default {
  name: 'Shorten',
  data() {
      return {
          email: null,
          password: null
      }
  },
  components: {
    mainLayout,
    shortrLink
  },
  methods: {
      // login() {
      //     const self = this

      //     httpAxios({
      //         url: '/login',
      //         method: 'POST',
      //         data: { email: self.email, password: self.password }
      //     }).then(async response => {
      //         self.$store.commit('LOGGED_USER', response.data)

      //         self.$router.go({ name: 'admin.dashboard' })
      //     })
      // }
  }
}