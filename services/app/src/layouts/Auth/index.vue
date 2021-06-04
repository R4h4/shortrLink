<template>
  <nav
    class="navbar navbar-expand-lg top-0 z-index-3 w-100 shadow-none my-3  navbar-transparent ">
    <div class="container">
      <a class="navbar-brand  text-primary " href="./" rel="tooltip" title="Shorter links for everyone" data-placement="bottom">
        <img src="@/assets/images/shortrLink_logo.png" style="height: 3rem; margin-top: -1rem;" />
      </a>
    </div>
  </nav>
  <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />

  <div class="page-header section-height-75">
      <div class="container">
        <div class="row">
          <div class="col-xl-4 col-lg-5 col-md-6 d-flex flex-column mx-auto">
            <slot />
          </div>

          <div class="col-md-6">
            <div class="oblique position-absolute top-0 h-100 d-md-block d-none me-n8">
              <div class="oblique-image bg-cover position-absolute fixed-top ms-auto h-100 z-index-0 ms-n6" 
                   :style="{ backgroundImage: 'url(\'' + require('@/assets/images/curved6.jpg') + '\')' }"></div>
            </div>
          </div>
        </div>  
      </div>
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
import { appConfig } from '@/config/app.js'

export default {
    name: 'AuthLayout',
    data() {
        return {
            appName: appConfig.APP_NAME
        }
    }
}
</script>
