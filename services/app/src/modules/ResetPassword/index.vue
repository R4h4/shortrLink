<template>
<authLayout>
  <div class="card card-plain mt-8">
    <div class="card-header pb-0 text-left bg-transparent">
      <h3 class="font-weight-bolder text-primary text-gradient">Reset Password</h3>
      <p class="mb-0">
        Enter your username to request a password reset.
      </p>
    </div>
    <div class="card-body">
      <form role="form text-left">
        <div class="mb-3">
           <input type="text" class="form-control" placeholder="username" aria-label="Username" v-model="username">
        </div>
        <div v-if="resetCode" class="mb-3">
            <input type="text" class="form-control" placeholder="ResetCpde" aria-label="ResetCode" v-model="resetCode">
        </div>
        <div class="text-center">
            <button type="button" class="btn bg-gradient-primary w-100 my-4 mb-2" @click="resetPassword">Request code</button>
        </div>
      </form>
    </div>
    <div class="card-footer text-center pt-0 px-lg-2 px-1">
      <p class="mb-4 text-sm mx-auto">
        Don't have an account?
        <a href="./sign-up" class="text-dark font-weight-bold">Sign up</a>
      </p>
    </div>
  </div>
</authLayout>
</template>

<script>
import authLayout from '@/layouts/Auth'

export default {
    name: 'ResetPassword',
    data() {
        return {
            username: null,
            resetCode: null,
            error: null
        }
    },
    components: {
        authLayout
    },
    methods: {
      resetPassword() {
          this.loading = true;
          this.$cognitoAuth.forgotPassword(
            this.username,
            (err, result) => {
              console.log(result);
              if (err.statusCode !== 200) {
                console.log(err);
              } else {
                this.$router.replace("/dashboard");
              }
            }
          );
        }
    }
}
</script>