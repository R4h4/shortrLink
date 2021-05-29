<template>
  <Navbar />
  <div class="container">
    <slot />
  </div>

  <footer class="footer py-5">
      <div class="container">
          <div class="row">
              <div class="col-8 mx-auto text-center mt-1">
                  <p class="mb-0 text-secondary">Copyright © {{ (new Date().getFullYear()) }} {{ appName }}.</p>
              </div>
          </div>
      </div>
  </footer>
</template>

<script>
import 'bootstrap/dist/js/bootstrap.min.js'
import '@fortawesome/fontawesome-free/css/all.min.css'
import { appConfig } from '@/config/app.js'
import Navbar from '@/components/Navbar'

export default {
    name: 'dashboardLayout',
    data() {
        return {
            appName: appConfig.APP_NAME
        }
    },
    components: {
      Navbar
    },
    mounted() {
      document.body.classList.add('g-sidenav-show', 'bg-gray-100')
    },
}
</script>

<style src='../Main/Main.css' />