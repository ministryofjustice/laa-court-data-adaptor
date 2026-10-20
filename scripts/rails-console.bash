#!/usr/bin/env bash

set -euo pipefail

usage() {
  echo "Usage: bash scripts/rails-console.bash --env <environment>"
  echo "  -e, --env   Target environment: uat, prod"
  echo "  -h, --help  Show this help"
}

environment=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env)
      if [[ $# -lt 2 || $2 == -* ]]; then
        echo "Missing value for $1." >&2
        usage >&2
        exit 1
      fi
      environment="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$environment" in
  uat|prod) ;;
  *)
    echo "Environment must either be uat or prod. Set it via --env." >&2
    usage >&2
    exit 1
    ;;
esac

command -v kubectl >/dev/null || {
  echo "kubectl is required." >&2
  exit 1
}

namespace="laa-court-data-adaptor-${environment}"
deployment="deployment/laa-court-data-adaptor-console"

cleanup() {
  status=$?
  trap - EXIT
  echo "Scaling ${deployment} in ${namespace} back to zero..." >&2
  if ! kubectl -n "$namespace" scale "$deployment" --replicas=0 --request-timeout=30s; then
    echo "Failed to scale down. Run: kubectl -n ${namespace} scale ${deployment} --replicas=0" >&2
    if [[ $status -eq 0 ]]; then
      status=1
    fi
  fi
  exit "$status"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'exit 129' HUP

kubectl -n "$namespace" scale "$deployment" --replicas=1 --request-timeout=30s
kubectl -n "$namespace" rollout status "$deployment" --timeout=5m
kubectl -n "$namespace" exec -it "$deployment" -- bin/rails console
