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
  }
}