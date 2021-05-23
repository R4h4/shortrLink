export default {
  region: process.env.AWS_REGION,
  IdentityPoolId: process.env.VUE_APP_COGNITO_USERPOOL_ID,
  UserPoolId: process.env.VUE_APP_COGNITO_USERPOOL_ID,
  ClientId: process.env.VUE_APP_COGNITO_CLIENT_ID
}