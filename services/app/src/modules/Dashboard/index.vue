<template>
  <dashboardLayout>
    <div class="d-flex justify-content-end">
      <button type="button" class="btn bg-gradient-primary" data-bs-toggle="modal" data-bs-target="#exampleModal">
        Create new link
      </button>
    </div>
    <div class="row">
      <div class="col-4">
      <div v-for="item in links" :key="item.id">
        <linkCard :link=item />
      </div>
      </div>
      <div class="col-8">
        <linkClicksCard />
      </div>
    </div>
    <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="false">
      <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title" id="exampleModalLabel">Create new link</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
          </div>
          <div class="modal-body">
            <shortrLink class="mt-2" />
          </div>
        </div>
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
import shortrLink from '@/components/LinkShortener'
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
    shortrLink,
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