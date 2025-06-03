#!/bin/sh

NAMESPACE=$1
VALUES_FILE=$2
TAG=$3

PINGDOM_IPS=$(curl -s https://my.pingdom.com/probes/ipv4 | tr -d ' ' | tr '\n' ',' | sed 's/,/\\,/g' | sed 's/\\,$//')
VPN_IPS=$(curl -s https://raw.githubusercontent.com/ministryofjustice/laa-ip-allowlist/main/cidrs.txt | tr -d ' ' | tr '\n' ',' | sed 's/,/\\,/g' | sed 's/\\,$//')

helm upgrade laa-court-data-adaptor ./helm_deploy/laa-court-data-adaptor \
  --install --wait \
  --namespace=$NAMESPACE \
  --values $VALUES_FILE \
  --set image.tag="$TAG" \
  --set-string pingdomIps="$PINGDOM_IPS" \
  --set-string vpnIps="$VPN_IPS"
