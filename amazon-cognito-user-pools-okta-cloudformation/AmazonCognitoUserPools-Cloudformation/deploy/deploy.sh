#!/usr/bin/env bash
set -euo pipefail

STACK_NAME="${STACK_NAME:-CognitoOktaFullStack}"
TEMPLATE_FILE="${TEMPLATE_FILE:-cloudformation/cognito-okta-full.yml}"

# Load .env if present
if [ -f .env ]; then
  set -o allexport; source .env; set +o allexport
fi

: "${OktaIssuerUrl:?OktaIssuerUrl env var is required}"
: "${OktaClientId:?OktaClientId env var is required}"
: "${OktaClientSecret:?OktaClientSecret env var is required}"
: "${CognitoDomainPrefix:?CognitoDomainPrefix env var is required}"
: "${CallbackURL:?CallbackURL env var is required}"
: "${LogoutURL:?LogoutURL env var is required}"

aws cloudformation deploy \
  --template-file "${TEMPLATE_FILE}" \
  --stack-name "${STACK_NAME}" \
  --parameter-overrides \
    OktaIssuerUrl="${OktaIssuerUrl}" \
    OktaClientId="${OktaClientId}" \
    OktaClientSecret="${OktaClientSecret}" \
    CognitoDomainPrefix="${CognitoDomainPrefix}" \
    CallbackURL="${CallbackURL}" \
    LogoutURL="${LogoutURL}" \
    UserPoolName="${UserPoolName:-MyCognitoUserPool}" \
  --capabilities CAPABILITY_NAMED_IAM
