<template>
  <dashboardLayout>
    Dashboard
  </dashboardLayout>
</template>

<script>
import dashboardLayout from '@/layouts/Dashboard'
// import httpAxios from '@/utils/http-axios'
import store from '@/store'

export default {
  name: 'Dashboard',
  data() {
      return {
      }
  },
  created() {
    const user = store.getters["auth/getUserInformation"]
    console.log(user)
  },
  components: {
    dashboardLayout,
  },
  methods: {
    
  },
}
</script>