import authLayout from '@/layouts/Auth'

export default {
    name: 'SignUp',
    data() {
        return {
            email: null,
            password: null,
            username: null
        }
    },
    components: {
        authLayout
    },
    methods: {
        signup() {
            console.log(self.$store)
            this.loading = true;
            this.$cognitoAuth.signup(
              this.username,
              this.email,
              this.password,
              (err, result) => {
                console.log(result);
                if (err.statusCode !== 200) {
                  console.log(err);
                  this.error = err;
                } else {
                  this.$router.replace("/dashboard");
                }
              }
            );
        }
    }
}