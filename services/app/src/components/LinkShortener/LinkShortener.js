import axios from 'axios';
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
          const response = await axios.post(
          'https://api-dev.shortrlink.com/short-links',
            {
              url: this.inputUrl
            }
          )
          const results = response.data
          console.log(results)
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
