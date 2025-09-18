#!/usr/bin/env bash
set -euo pipefail

# Load .env if present
if [ -f .env ]; then
  set -o allexport
  # shellcheck disable=SC1091
  source .env
  set +o allexport
fi

: "${OKTA_DOMAIN:?Need to set OKTA_DOMAIN env var (e.g. dev-12345.okta.com)}"
: "${OKTA_API_TOKEN:?Need to set OKTA_API_TOKEN env var}"

APP_NAME="${APP_NAME:-CognitoOIDCApp}"
REDIRECT_URI="${REDIRECT_URI:-https://my-cognito-domain.auth.region.amazoncognito.com/oauth2/idpresponse}"
LOGOUT_URI="${LOGOUT_URI:-https://myapp.example.com/logout}"

# Ensure jq exists
if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not installed. Install jq and re-run."
  exit 2
fi

# Create OIDC app integration in Okta
resp=$(curl -s -X POST "https://${OKTA_DOMAIN}/api/v1/apps" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "oidc_client",
    "label": "'"${APP_NAME}"'",
    "signOnMode": "OPENID_CONNECT",
    "credentials": {
      "oauthClient": {
        "autoKeyRotation": true,
        "token_endpoint_auth_method": "client_secret_basic"
      }
    },
    "settings": {
      "oauthClient": {
        "response_types": [
          "code"
        ],
        "grant_types": [
          "authorization_code",
          "refresh_token"
        ],
        "application_type": "web",
        "redirect_uris": [
          "'"${REDIRECT_URI}"'"
        ],
        "post_logout_redirect_uris": [
          "'"${LOGOUT_URI}"'"
        ],
        "issuer_mode": "ORG_URL",
        "consent_method": "REQUIRED"
      }
    }
  }')

mkdir -p outputs
echo "$resp" > outputs/okta_oidc.json

CLIENT_ID=$(echo "$resp" | jq -r '.credentials.oauthClient.client_id')
CLIENT_SECRET=$(echo "$resp" | jq -r '.credentials.oauthClient.client_secret')

echo "Created OIDC App: client_id = ${CLIENT_ID}"
echo "Saved full response to outputs/okta_oidc.json (do not commit)"
# avoid printing secrets directly to logs
# echo "client_secret = ${CLIENT_SECRET}"
