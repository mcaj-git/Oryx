#!/bin/bash
# --------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.
# --------------------------------------------------------------------------------------------

set -o pipefail

declare -r REPO_DIR=$( cd $( dirname "$0" ) && cd .. && cd .. && pwd )
source $REPO_DIR/build/__variables.sh

declare -r outPmeFile="$BUILD_ARTIFACTSTAGINGDIRECTORY/drop/images/oryxprodmcr-buildpack-images-mcr.txt" 
declare -r outNonPmeFile="$BUILD_ARTIFACTSTAGINGDIRECTORY/drop/images/oryxmcr-buildpack-images-mcr.txt" 
declare -r sourceImageRepo="oryxdevmcr.azurecr.io/public/oryx"
declare -r prodNonPmeImageRepo="oryxmcr.azurecr.io/public/oryx"
declare -r prodPmeImageRepo="oryxprodmcr.azurecr.io/public/oryx"

sourceBranchName=$BUILD_SOURCEBRANCHNAME

packImage="$sourceImageRepo/pack:Oryx-CI.$RELEASE_TAG_NAME"
echo "Pulling pack image '$packImage'..."
docker pull "$packImage"
echo "Retagging pack image with '$RELEASE_TAG_NAME'..."
echo "$prodNonPmeImageRepo/pack:$RELEASE_TAG_NAME">>"$outNonPmeFile"
docker tag "$packImage" "$prodNonPmeImageRepo/pack:$RELEASE_TAG_NAME"

echo "$prodPmeImageRepo/pack:$RELEASE_TAG_NAME">>"$outPmeFile"
docker tag "$packImage" "$prodPmeImageRepo/pack:$RELEASE_TAG_NAME"

if [ "$sourceBranchName" == "master" ]; then
    echo "Retagging pack image with 'stable'..."
    docker tag "$packImage" "$prodPmeImageRepo/pack:stable"
    echo "$prodNonPmeImageRepo/pack:stable">>"$outNonPmeFile"

    docker tag "$packImage" "$prodPmeImageRepo/pack:stable"
    echo "$prodPmeImageRepo/pack:stable">>"$outPmeFile"
else
    echo "Not creating 'stable' or 'latest' tags as source branch is not 'master'. Current branch is $sourceBranchName"
fi


echo "printing tags for PME ACR ..."
cat $outPmeFile
echo "printing tags for Non PME ACR ..."
cat $outNonPmeFile