<template>
  <div @click="setSelected()" class="card move-on-hover mb-3">
    <div class="card-body p-3">
      <div class="row">
          <div class="links">
            <h5 class="text-capitalize font-weight-bold mb-0">{{  link.short_link ? link.short_link : link.id }}</h5>
            <div class="text-sm mb-2">
              {{ link.url }}
            </div>
            <div class="row">
              <div class="col">
                <span class="text-sm">
                  {{ link.clicks }} clicks
                </span>
              </div>
              <div class="col">
                <div class="text-sm">
                  {{ days_ago }} days ago
                </div>
              </div>
            </div>
          </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'linkCard',
  props: {
    link: Object
  },
  data() {
    return {
      days_ago: null
    }
  },
  mounted() {
    const now = Date.now()
    const Difference_In_Time = Date.parse(this.link.createdAt) - now;
    this.days_ago = Math.trunc( Difference_In_Time / (1000 * 3600 * 24) * -1 )
    console.log(this.days_ago)
    // var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
  },
  methods: {
    setSelected() {
      this.$router.push({ query: { id: this.link.id }})
    }
  },
}
</script>