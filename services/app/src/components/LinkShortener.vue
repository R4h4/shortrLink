<template>
  <div class="hello">
    <h1>{{ msg }}</h1>
    <input v-model="inputUrl" placeholder="https://www.google.com/" />
    <button v-on:click="shortenOrCopyLink">{{ buttonText }}</button>
  </div>
</template>

<script>
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
        if (validURL(this.inputUrl)) {
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
        } 
      } else {
        copyTextToClipboard(this.inputUrl)
      }
    }
  }
}

function validURL(str) {
  var pattern = new RegExp('^(https?:\\/\\/)?'+ // protocol
    '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ // domain name
    '((\\d{1,3}\\.){3}\\d{1,3}))'+ // OR ip (v4) address
    '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ // port and path
    '(\\?[;&a-z\\d%_.~+=-]*)?'+ // query string
    '(\\#[-a-z\\d_]*)?$','i'); // fragment locator
  return !!pattern.test(str);
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
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
