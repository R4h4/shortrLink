import mainLayout from '@/layouts/Main'
import shortrLink from '@/components/LinkShortener'

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