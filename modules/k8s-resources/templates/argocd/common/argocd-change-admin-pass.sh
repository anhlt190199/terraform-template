#!/bin/bash

kubectl patch secret -n argocd argocd-secret \
  -p '{"stringData": {
        "admin.password": "'$(htpasswd -bnBC 10 "" arganhlt#212241905X22! | tr -d ':\n')'",
        "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'
