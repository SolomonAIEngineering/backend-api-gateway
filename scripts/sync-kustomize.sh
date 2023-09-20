#!/bin/bash
service_name=api-gateway
namespace=platform
charts=charts/$service_name

# generate the base kustomizations
generate_base_kustomizations() {
    local service_name="$1"
    local charts="$2"
    
    # Generate the base kustomizations using helm and awk
    helm template "$service_name" "$charts" -n $namespace> output.yaml

    awk '
    BEGIN {buf=""}
    /^---/ {
        if (kind != "") {
            file = "kustomize/base/" tolower(kind) ".yaml";
            if (seen[file]++) {
                file = "kustomize/base/" tolower(kind) "-" seen[file] ".yaml";
            }
            print buf > file;
        }
        buf = $0 ORS;
        next;
    }
    /^kind: / {
        kind = $2;
    }
    {
        buf = buf $0 ORS;
    }
    END {
        if (kind != "") {
            file = "kustomize/base/" tolower(kind) ".yaml";
            if (seen[file]++) {
                file = "kustomize/base/" tolower(kind) "-" seen[file] ".yaml";
            }
            print buf > file;
        }
    }
    ' output.yaml

    rm output.yaml
}


generate_kustomization() {
    local dir="kustomize/base"
    local kustomization_file="$dir/kustomization.yaml"

    # Begin writing the Kustomization file
    echo "apiVersion: kustomize.config.k8s.io/v1beta1" > "$kustomization_file"
    echo "kind: Kustomization" >> "$kustomization_file"
    echo "namespace: $namespace" >> "$kustomization_file"  # Add this line
    echo "resources:" >> "$kustomization_file"

    for file in $dir/*.yaml; do
        # Exclude kustomization.yaml from the list
        if [ "$(basename $file)" != "kustomization.yaml" ]; then
            echo "- $(basename $file)" >> "$kustomization_file"
        fi
    done
}

create_directory() {
    local dir="$1"
    mkdir -p "$dir"
}

generate_helm_template() {
    local service_name="$1"
    local charts="$2"
    local valuesfileName="$3"
    helm template "$service_name" "$charts" -f $charts/$valuesfileName --set linkerd.profile.enabled=false -n platform > output.yaml
}

parse_helm_output() {
    local dir="$1"
    awk -v dir="$dir" '
    BEGIN {buf=""}
    /^---/ {
        if (kind != "") {
            file = dir "/patch-" tolower(kind) ".yaml";
            if (seen[file]++) {
                file = dir "/patch-" tolower(kind) "-" seen[file] ".yaml";
            }
            print buf > file;
        }
        buf = $0 ORS;
        next;
    }
    /^kind: / {
        kind = $2;
    }
    {
        buf = buf $0 ORS;
    }
    END {
        if (kind != "") {
            file = dir "/patch-" tolower(kind) ".yaml";
            if (seen[file]++) {
                file = dir "/patch-" tolower(kind) "-" seen[file] ".yaml";
            }
            print buf > file;
        }
    }
    ' output.yaml
}

create_base_kustomization_file() {
    local dir="$1"
    local kustomization_file="$dir/kustomization.yaml"
    echo "apiVersion: kustomize.config.k8s.io/v1beta1" > "$kustomization_file"
    echo "kind: Kustomization" >> "$kustomization_file"
    echo "namespace: $namespace" >> "$kustomization_file"  # Add this line
    echo "resources:" >> "$kustomization_file"
}

populate_kustomization_file() {
    local dir="$1"
    local kustomization_file="$dir/kustomization.yaml"
    for file in "$dir"/patch-*.yaml; do
        if [ "$(basename "$file")" != "kustomization.yaml" ]; then
            echo "- $(basename "$file")" >> "$kustomization_file"
        fi
    done
}

create_overlay_kustomization_file() {
    local dir="$1"
    local kustomization_file="$dir/kustomization.yaml"
    
    echo "apiVersion: kustomize.config.k8s.io/v1beta1" > "$kustomization_file"
    echo "kind: Kustomization" >> "$kustomization_file"
    echo "namespace: platform" >> "$kustomization_file"  # Add this line
    echo "bases:" >> "$kustomization_file"
    echo "- ../../base" >> "$kustomization_file"
    echo "patchesStrategicMerge:" >> "$kustomization_file"
}

populate_overlay_kustomization_file() {
    local dir="$1"
    local kustomization_file="$dir/kustomization.yaml"
    
    for file in "$dir"/patch-*.yaml; do
        echo "- $(basename "$file")" >> "$kustomization_file"
    done
}

generate_overlay_kustomizations() {
    local service_name="$1"
    local charts="$2"
    local dir="$3"
    local valuesFileName="$4"

    create_directory "$dir"
    generate_helm_template "$service_name" "$charts" "$valuesFileName"
    parse_helm_output "$dir"
    create_overlay_kustomization_file "$dir"
    populate_overlay_kustomization_file "$dir"
}


# Call the function
generate_base_kustomizations $service_name $charts
generate_kustomization
generate_overlay_kustomizations $service_name $charts kustomize/overlays/production values.production.yaml
generate_overlay_kustomizations $service_name $charts kustomize/overlays/staging values.staging.yaml


cd kustomize/base && kustomize edit fix --vars && cd ../..
kustomize build kustomize/base

cd kustomize/overlays/production && kustomize edit fix --vars && cd ../../..
kustomize build kustomize/overlays/production 

cd kustomize/overlays/staging && kustomize edit fix --vars && cd ../../..
kustomize build kustomize/overlays/staging

rm output.yaml

./scripts/validate.sh
