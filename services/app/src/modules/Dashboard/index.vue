<template>
  <dashboardLayout>
    <div class="row mt-4">
      <div class="col-4">
      <div v-for="item in links" :key="item.id">
        <linkCard :link=item />
      </div>
      </div>
      <div class="col-8">
        <linkClicksCard />
      </div>
    </div>
  </dashboardLayout>
</template>

<script>
/* eslint-disable */
import * as popper from "../../assets/js/core/popper.min.js"
import * as bootstrap from  "../../assets/js/core/bootstrap.min.js"
/* eslint-enable */

// <script src="../assets/js/soft-ui-dashboard.min.js">
import dashboardLayout from '@/layouts/Dashboard'
import httpAxios from '@/utils/http-axios'
// import store from '@/store'
import linkCard from './components/LinkCard'
import linkClicksCard from './components/LinkClicksCard'

export default {
  name: 'Dashboard',
  data() {
      return {
        links: null
      }
  },
  created() {
    this.fetchData()
  },
  watch: {
    // call again the method if the route changes
    '$route': 'fetchData'
  },
  components: {
    dashboardLayout,
    linkCard,
    linkClicksCard
  },
  methods: {
    open_new_link_modal() {
      console.log('Opening modal')
    },
    async fetchData() {
      const res = await httpAxios.get('/short-links')
      this.links = res.data.links;
      console.log(this.links)
    }
  },
}
</script>