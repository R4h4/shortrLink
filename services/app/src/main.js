import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import CognitoAuth from "./plugins/cognito";
// import config from "@/config";

const app = createApp(App)
app.use(CognitoAuth)
app.use(router)
app.use(store)
app.mount('#app')
