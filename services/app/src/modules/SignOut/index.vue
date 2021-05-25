<template>
<authLayout>
</authLayout>
</template>

<script>
import authLayout from '@/layouts/Auth'

export default {
  name: 'SignOut',
  components: {
    authLayout
  },
  created() {
    this.$cognitoAuth.logout()
    this.$router.go({ name: 'Shorten' });
  },
}
</script>