import httpAxios from '@/utils/http-axios'
import store from '@/store'
import { appConfig } from '@/config/app'
import { isValidHttpUrl, copyTextToClipboard } from './utils'

export default {
  name: 'shortrLink',
  data() {
    return {
      inputUrl: null,
      buttonText: 'Shorten'
    }
  },
  props: {
    msg: String
  },

  methods: {
    async shortenOrCopyLink() {
      if (this.buttonText == 'Shorten') {
        if (isValidHttpUrl(this.inputUrl)) {
          let api_endpoint = (
            store.getters['auth/isAuthenticated'] 
            ? appConfig.BACKEND_URL + '/short-links' 
            : api_endpoint = appConfig.BACKEND_URL + '/short-links/anonymous')
          const response = await httpAxios.post(
            api_endpoint,
            {
              url: this.inputUrl
            }
          )
          const results = response.data
          this.buttonText = 'Copy'
          this.inputUrl = results.shortUrl
        } else {
          console.log('Not a valid link')
        }
      } else {
        copyTextToClipboard(this.inputUrl)
      }
    }
  }
}
