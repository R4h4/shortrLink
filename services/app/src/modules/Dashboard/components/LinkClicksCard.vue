<template>
  <div>
    test
    <clickStatsChart />
  </div>
</template>

<script>
import clickStatsChart from './ClickStatsChart.vue'

export default {
  name: 'linkClicksCard',
  components: {
    clickStatsChart
  }
}
</script>