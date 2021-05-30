<template>
  <div class="card p-4">
    <div class="fs-4">
      {{ link.short_link }}
    </div>
    <p>
      {{link.title}}
    </p>
    <p>
      {{link.url}}
    </p>
    <clickStatsChart />
  </div>
</template>

<script>
import clickStatsChart from './ClickStatsChart.vue'

export default {
  name: 'linkClicksCard',
  props: {
    link: Object
  },
  components: {
    clickStatsChart
  },
  mounted() {
    console.log(this.link.id)
  },
}
</script>