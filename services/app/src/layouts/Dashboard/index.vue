<template>
  <nav
    class="navbar navbar-expand-lg top-0 z-index-3 w-100 shadow-none my-3  navbar-transparent ">
    <div class="container">
      <a class="navbar-brand  text-primary " href="./" rel="tooltip" title="Shorter links for everyone" data-placement="bottom">
        <img src="@/assets/images/shortrLink_logo.png" style="height: 3rem; margin-top: -1rem;" />
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navigation" aria-controls="navigation" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navigation">
      <ul class="nav navbar-nav ms-auto w-100 justify-content-end">
        <li class="nav-item px-3">
          <a class="nav-link text-secondary" href="https://github.com/R4h4/shortrLink" target="_blank">
            GitHub
          </a>
        </li>
      </ul>

      <ul class="navbar-nav">
        <a class="nav-link text-secondary" href="./sign-out">
          Logout
        </a>
      </ul>
    </div>
    </div>
  </nav>
  <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,400,600,700" rel="stylesheet" />

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
import { appConfig } from '@/config/app.js'

export default {
    name: 'dashboardLayout',
    data() {
        return {
            appName: appConfig.APP_NAME
        }
    }
}
</script>

<style src='../Main/Main.css' />