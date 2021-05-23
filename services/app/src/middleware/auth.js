/* eslint-disable */
import {CognitoAuth, StorageHelper} from 'amazon-cognito-auth-js';
import * as AWS from 'aws-sdk/global';
import IndexRouter from '../router/index';
import UserInfoStore from '@/store/user-info-store';
import UserInfoApi from '@/utils/user-info-api';


const CLIENT_ID = process.env.VUE_APP_COGNITO_CLIENT_ID;
const APP_DOMAIN = process.env.VUE_APP_COGNITO_APP_DOMAIN;
const REDIRECT_URI = process.env.VUE_APP_COGNITO_REDIRECT_URI;
const USERPOOL_ID = process.env.VUE_APP_COGNITO_USERPOOL_ID;
const REDIRECT_URI_SIGNOUT = process.env.VUE_APP_COGNITO_REDIRECT_URI_SIGNOUT;
const APP_URL = process.env.VUE_APP_APP_URL;

var authData = {
    ClientId : CLIENT_ID, // Your client id here
    AppWebDomain : APP_DOMAIN,
    TokenScopesArray : ['openid', 'email'],
    RedirectUriSignIn : REDIRECT_URI,
    RedirectUriSignOut : REDIRECT_URI_SIGNOUT,
    UserPoolId : USERPOOL_ID,
}

var auth = new CognitoAuth(authData);
auth.userhandler = {
    onSuccess: function(result) {
        console.log("On Success result", result);
        UserInfoStore.setLoggedIn(true);
        UserInfoApi.getUserInfo().then(response => {
            IndexRouter.push('/');
        });
        
        
    },
    onFailure: function(err) {
        UserInfoStore.setLoggedOut();
        IndexRouter.go({ path: '/error', query: { message: 'Login failed due to ' + err } });
    }
};

function getUserInfoStorageKey(){
    var keyPrefix = 'CognitoIdentityServiceProvider.' + auth.getClientId();
    var tokenUserName = auth.signInUserSession.getAccessToken().getUsername();
    var userInfoKey = keyPrefix + '.' + tokenUserName + '.userInfo';
    return userInfoKey;
}


function login(user, password) {
  var authenticationData = {
    Username: user,
    Password: password,
  };
  var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(
    authenticationData
  );
  var authenticationDetails = new AmazonCognitoIdentity.AuthenticationDetails(
    authenticationData
  );
  var poolData = {
    UserPoolId: authData.UserPoolId,
    ClientId: authData.ClientId
  };
  var userPool = new AmazonCognitoIdentity.CognitoUserPool(poolData);
  var userData = {
    Username: user,
    Pool: userPool,
  };
  var cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
  var cognitoUser = new AmazonCognitoIdentity.CognitoUser(userData);
  cognitoUser.authenticateUser(authenticationDetails, {
    onSuccess: function(result) {
      var accessToken = result.getAccessToken().getJwtToken();

      //POTENTIAL: Region needs to be set if not already set previously elsewhere.
      AWS.config.region = 'eu-west-1';

      let cognito_url = `cognito-idp.${AWS.config.region}.amazonaws.com/${authData.UserPoolId}`
      AWS.config.credentials = new AWS.CognitoIdentityCredentials({
        IdentityPoolId: authData.IdentityPoolId, // your identity pool id here
        Logins: {
          // Change the key below according to the specific region your user pool is in.
          cognito_url: result
            .getIdToken()
            .getJwtToken(),
        },
      });

      //refreshes credentials using AWS.CognitoIdentity.getCredentialsForIdentity()
      AWS.config.credentials.refresh(error => {
        if (error) {
          console.error(error);
        } else {
          // Instantiate aws sdk service objects now that the credentials have been updated.
          // example: var s3 = new AWS.S3();
          console.log('Successfully logged!');
        }
      });
    },

    onFailure: function(err) {
      alert(err.message || JSON.stringify(err));
    },
  });
}

var storageHelper = new StorageHelper();
var storage = storageHelper.getStorage();

export default {
    auth: auth,
    login,
    // login(){
    //     auth.getSession();
    // },
    logout(){
        if (auth.isUserSignedIn()) {
            var userInfoKey = this.getUserInfoStorageKey();
            auth.signOut();

            storage.removeItem(userInfoKey);
        }
    },
    getUserInfoStorageKey,
}
