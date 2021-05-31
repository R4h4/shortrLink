<template>
  <div class="card p-4">
    <div class="row">
      <div class="col-8">
        <h3 class="font-weight-bold">
          {{ link.short_link }}
        </h3>
      </div>
      <div class="col-4 m-auto">
        <!-- This is where I will put the link-bar -->
      </div>
    </div>

    <div>
      {{link.title}} something
    </div>
    <a>
      {{link.url}}
    </a>
    <clickStatsChart
      v-if="state.isLoaded"
      v-bind:chartData="state.chartData" 
      :chartOptions="state.chartOptions" 
    />
  </div>
</template>

<script>
import clickStatsChart from './ClickStatsChart.vue'
import httpAxios from '@/utils/http-axios'

export default {
  name: 'linkClicksCard',
  props: {
    link: Object
  },
  data() {
    return {
      state: {
        isLoaded: false,
        chartData: {},
        chartOptions: {
          responsive: true
        }
      }
    }
  },
  watch: {
    // call again the method if the route changes
    '$route': 'getData'
  },
  components: {
    clickStatsChart
  },
  mounted() {
    this.getData()
  },
  methods: {
    async getData() {
      this.state.isLoaded = false
      await httpAxios.get(`/short-links/${this.$route.query.id}/stats`)
        .then((result) => {
          this.state.chartData = {
            labels: ['1', '2', '3', '4', '5', '6', '7', '1', '2', '3', '4', '5', '6', '7'],
            datasets: [
              {
                label: 'Clicks',
                backgroundColor: '#f87979',
                data: result.data.timeSeries
              }
            ]
          }
          this.state.isLoaded = true
        })
        .catch((err) => {
          console.error(err)
        })
    }
  },
}
</script>