#!/bin/bash
#
set -euo pipefail

if [[ -z "${SSH_AGENT_PID:-}" ]] ; then
    echo "Starting an ephemeral ssh-agent" >&2;
    eval "$(ssh-agent -s)"
  fi

ssh_key=$(vault kv get --field=data secret/buildkite/vault-buildkite-demo/private_ssh_key)

#echo "${ssh_key}" > /tmp/temp_key

#chmod 600 /tmp/temp_key
#ssh-add /tmp/temp_key

echo "${ssh_key}" | env SSH_ASK_PASS="/bin/false" ssh-add -vvv - 


echo "cleaning up"

if [[ -n "${SSH_AGENT_PID:-}" ]] && ps -p "$SSH_AGENT_PID" &>/dev/null; then
  echo "~~~ Stopping ssh-agent ${SSH_AGENT_PID}"
  ssh-agent -k
fi

rm /tmp/temp_key
