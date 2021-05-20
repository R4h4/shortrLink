import axios from 'axios';

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

function isValidHttpUrl(string) {
  let url;
  
  try {
    url = new URL(string);
  } catch (_) {
    return false;  
  }

  return url.protocol === "http:" || url.protocol === "https:";
}

function fallbackCopyTextToClipboard(text) {
  var textArea = document.createElement("textarea");
  textArea.value = text;
  
  // Avoid scrolling to bottom
  textArea.style.top = "0";
  textArea.style.left = "0";
  textArea.style.position = "fixed";

  document.body.appendChild(textArea);
  textArea.focus();
  textArea.select();

  try {
    var successful = document.execCommand('copy');
    var msg = successful ? 'successful' : 'unsuccessful';
    console.log('Fallback: Copying text command was ' + msg);
  } catch (err) {
    console.error('Fallback: Oops, unable to copy', err);
  }

  document.body.removeChild(textArea);
}
function copyTextToClipboard(text) {
  if (!navigator.clipboard) {
    fallbackCopyTextToClipboard(text);
    return;
  }
  navigator.clipboard.writeText(text).then(function() {
    console.log('Async: Copying to clipboard was successful!')
  }, function(err) {
    console.error('Async: Could not copy text: ', err)
  })
}