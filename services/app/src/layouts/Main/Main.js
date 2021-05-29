import { appConfig } from '@/config/app.js'
import Navbar from '@/components/Navbar'

export default {
    name: 'mainLayout',
    data() {
        return {
            appName: appConfig.APP_NAME
        }
    },
    components: {
        Navbar
    },
}