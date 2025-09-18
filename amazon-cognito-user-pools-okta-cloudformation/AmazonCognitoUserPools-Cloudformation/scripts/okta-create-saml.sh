#!/usr/bin/env bash
set -euo pipefail

if [ -f .env ]; then
  set -o allexport; source .env; set +o allexport
fi

: "${OKTA_DOMAIN:?Need OKTA_DOMAIN}"
: "${OKTA_API_TOKEN:?Need OKTA_API_TOKEN}"
: "${METADATA_URL:?Need METADATA_URL (or set METADATA_FILE and read it)}"

IDP_NAME="${IDP_NAME:-ExternalSAMLIdP}"

payload=$(cat <<EOF
{
  "type": "SAML2",
  "name": "${IDP_NAME}",
  "protocol": {
    "type": "SAML2",
    "endpoints": {
      "sso": { "url": "${METADATA_URL}", "binding": "HTTP-Redirect" }
    }
  },
  "policy": {
    "provisioning": { "action": "NONE", "profileMaster": false }
  }
}
EOF
)

resp=$(curl -s -X POST "https://${OKTA_DOMAIN}/api/v1/idps" \
  -H "Authorization: SSWS ${OKTA_API_TOKEN}" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$payload")

mkdir -p outputs
echo "$resp" > outputs/okta_saml_idp.json

echo "Created SAML IdP: saved outputs/okta_saml_idp.json"
