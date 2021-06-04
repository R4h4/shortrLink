<template>
  <loader-component v-if="displayLoader"/>
  <router-view/>
  <notification-component/>
</template>

<script>
import '@fortawesome/fontawesome-free/css/all.min.css'
import '@/assets/css/soft-design-system.css'
import '@/assets/css/nucleo-icons.css'
// Core
import '@/assets/js/core/popper.min.js'
import '@/assets/js/core/bootstrap.min.js'
// Theme JS
import '@/assets/js/soft-design-system.min.js'

import { mapGetters } from 'vuex'
import loaderComponent from '@/components/Loader'
import notificationComponent from '@/components/Notification'
export default {
    name: 'App',
    components: { loaderComponent, notificationComponent },
    computed: {
        ...mapGetters({
            displayLoader: 'getDisplayLoader'
        })
    }
}
</script>