<template>
  <loader-component v-if="displayLoader"/>
  <router-view/>
  <notification-component/>
</template>

<script>
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