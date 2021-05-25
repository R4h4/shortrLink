import authLayout from '@/layouts/Auth'

export default {
    name: 'SignIn',
    data() {
        return {
            username: null,
            password: null,
            error: null
        }
    },
    components: {
        authLayout
    },
    methods: {
        login() {
            this.loading = true;
            this.$cognitoAuth.authenticate(
              this.username,
              this.password,
              (err, result) => {
                console.log(result);
                if (err) {
                  console.log(`Got error: ${err}`);
                  this.error = err;
                } else {
                  console.log('Redirecting to dashboard')
                  this.$router.go({ name: 'dashboard' });
                }
              }
            );
          }
        // login() {
        //     const self = this
        //     auth.login(self.email, self.password)

        //     httpAxios({
        //         url: '/login',
        //         method: 'POST',
        //         data: { email: self.email, password: self.password }
        //     }).then(async response => {
        //         self.$store.commit('LOGGED_USER', response.data)

        //         self.$router.go({ name: 'admin.dashboard' })
        //     })
        // }
    }
}