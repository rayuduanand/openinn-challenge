#!/bin/bash
set -e

for chart in helm/*; do
  if [ -d "$chart" ] && [ -f "$chart/Chart.yaml" ]; then
    echo "Linting $chart..."
    helm lint "$chart"
    yamllint "$chart"
  fi
done