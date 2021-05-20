import { appConfig } from '@/config/app.js'

export default {
    name: 'mainLayout',
    data() {
        return {
            appName: appConfig.APP_NAME
        }
    }
}