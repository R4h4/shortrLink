import authLayout from '@/layouts/Auth'
import httpAxios from '@/utils/http-axios'

export default {
    name: 'SignUp',
    data() {
        return {
            email: null,
            password: null
        }
    },
    components: {
        authLayout
    },
    methods: {
        login() {
            const self = this

            httpAxios({
                url: '/login',
                method: 'POST',
                data: { email: self.email, password: self.password }
            }).then(async response => {
                self.$store.commit('LOGGED_USER', response.data)

                self.$router.go({ name: 'admin.dashboard' })
            })
        }
    }
}