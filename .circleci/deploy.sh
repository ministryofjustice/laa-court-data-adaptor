#!/bin/sh

usage() {
  echo "Usage: $0 --namespace NAME --values-file FILE --tag TAG [--cert-fingerprint FINGERPRINT] [--hmcts-ips IPS]"
}

NAMESPACE=
VALUES_FILE=
TAG=
CERT_FINGERPRINT=
HMCTS_IPS=

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --namespace|--values-file|--tag|--cert-fingerprint|--hmcts-ips)
      if [ "$#" -lt 2 ] || [ -z "$2" ]; then
        echo "Missing value for $1" >&2
        usage >&2
        exit 1
      fi
      case "$2" in
        -*)
          echo "Missing value for $1: received option $2" >&2
          usage >&2
          exit 1
          ;;
      esac
      case "$1" in
        --namespace) NAMESPACE=$2 ;;
        --values-file) VALUES_FILE=$2 ;;
        --tag) TAG=$2 ;;
        --cert-fingerprint) CERT_FINGERPRINT=$2 ;;
        --hmcts-ips) HMCTS_IPS=$2 ;;
      esac
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$NAMESPACE" ] || [ -z "$VALUES_FILE" ] || [ -z "$TAG" ]; then
  echo "--namespace, --values-file and --tag are required" >&2
  usage >&2
  exit 1
fi

PINGDOM_IPS=$(curl -s https://my.pingdom.com/probes/ipv4 | tr -d ' ' | tr '\n' ',' | sed 's/,/\\,/g' | sed 's/\\,$//')
VPN_IPS=$(curl -s https://raw.githubusercontent.com/ministryofjustice/laa-ip-allowlist/main/cidrs.txt | tr -d ' ' | tr '\n' ',' | sed 's/,/\\,/g' | sed 's/\\,$//')
# Helm parses commas as assignment separators, even with --set-string.
HMCTS_IPS=$(printf '%s' "$HMCTS_IPS" | sed 's/,/\\,/g')

helm upgrade laa-court-data-adaptor ./helm_deploy/laa-court-data-adaptor \
  --install --wait \
  --namespace="$NAMESPACE" \
  --values "$VALUES_FILE" \
  --set image.tag="$TAG" \
  --set-string pingdomIps="$PINGDOM_IPS" \
  --set-string vpnIps="$VPN_IPS" \
  --set-string certFingerprint="$CERT_FINGERPRINT" \
  --set-string hmctsIps="$HMCTS_IPS"
