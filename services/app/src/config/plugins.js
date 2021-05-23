import {createCognitoPlugin} from '@/plugins/cognito.js';
import config from "@/config";

// we get app context here since we passed a function to `.use()` method in the main.js?
export default (app) => {
    // here we pass an object to `app.use` so it will attempt to call our `install` function it seems.
    app.use(createCognitoPlugin(config));
}