#!/bin/bash
#
# This script will set up the vault server created via `docker compose`
# with the bits we need to use the vault secrets buildkite plugin

# In the docker-compose config, the root token is "buildkite-is-cool"
# we'll reference the var here, but you could hardcode it if you want
# We also want to ensure we aren't trying to use the default of https
# for the cli commands
set -euo pipefail


export VAULT_TOKEN="${VAULT_DEV_ROOT_TOKEN_ID:-"buildkite-is-cool"}"
export VAULT_ADDRESS="http://127.0.0.1:8220"

# enable secret mountpath kv
vault secrets enable kv

# put some data in the kv store

vault kv put secret/buildkite/vault-buildkite-demo/env some_value="alpacas" && sleep 1
vault kv put kv/buildkite/vault-buildkite-demo/env artifactory_user="test" && sleep 1

# enable approle authentication
vault auth enable approle && sleep 1

# create the policy that will be scoped to the token requested by the agent role
cat ./config/agent-policy.hcl | vault policy write buildkite -

sleep 1

# Create our agent role, and attach the agent policies created earlier
vault write auth/approle/role/buildkite token_policies="buildkite" token_ttl=1h token_max_ttl=4h && sleep 1

# Now we can collect our ROLE_ID and SECRET_ID
echo "~~~ Successfully configured Vault at ${VAULT_ADDRESS}"
