import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
//import config from "@/config";
import plugins from './config/plugins.js';

const app = createApp(App)
app.use(plugins)
app.use(router)
app.use(store)
app.mount('#app')

app.provide('cognitoAuth', app.config.globalProperties.$cognitoAuth)
