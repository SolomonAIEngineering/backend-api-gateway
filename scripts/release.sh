#!/bin/bash

# Define the output file name and version variables
OUTPUT_FILE_NAME="config/krakend-flexible-config.compiled.json"
PATCH_VERSION=$(grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%s.%d", $2, $3, $4+1 }')
MINOR_VERSION=$(grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%d.0", $2, $3+1 }')
MAJOR_VERSION=$(grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%d.0.0", $2+1 }')
VERSION=$(grep 'VERSION' pkg/version/version.go | awk -F'[".]' '{ printf "%s.%s.%s", $2, $3, $4 }')

# Print the next version information
echo "Next Major Version: $MAJOR_VERSION"
echo "Next Minor Version: $MINOR_VERSION"
echo "Next Patch Version: $PATCH_VERSION"

# Function to update version
update_version() {
    next="$1"
    current="$VERSION"
    echo "version-set: current: $current, next: $next"
    FILES=(
        "pkg/version/version.go"
        "charts/api-gateway/values.yaml"
        "charts/api-gateway/values.production.yaml"
        "charts/api-gateway/values.staging.yaml"
        "charts/api-gateway/Chart.yaml"
        "kustomize/base/deployment.yaml"
        "kustomize/overlays/production/patch-deployment.yaml"
        "kustomize/overlays/staging/patch-deployment.yaml"
    )
    for file in "${FILES[@]}"; do
        sed -i '' "s/$current/$next/g" "$file"
    done
    echo "Version $next set in code, deployment, chart, and kustomize"
    # Uncomment the line below if you want to run 'make sync-kustomize'
    # make sync-kustomize
}

# Example usage of update_version function
# update_version $MAJOR_VERSION
