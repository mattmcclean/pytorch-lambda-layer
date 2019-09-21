#!/bin/bash

BUILD_DIR="./build/requirements"
PACKAGE_DIR="./build/python"
LAYER_NAME="PyTorchLayer"
REQUIREMENTS_ZIPFILE=".requirements.zip"
FINAL_ZIPFILE="layer.zip"
COMPATIBLE_RUNTIMES="python3.6 python3.7"
S3_BUCKET="mmcclean-lambda-code"
S3_KEY="layers/${LAYER_NAME}/${FINAL_ZIPFILE}"

#do cleanup of previous zip file
echo "Clean up previous build files"
rm layer.zip
#cleanup previous build artifacts
rm -rf .aws-sam/build/DummyFunction
#clean out the build folder
rm -rf build
#make our build folder
mkdir -p $BUILD_DIR
mkdir -p $PACKAGE_DIR
#build the layer
echo "Building new python files in dir: $BUILD_DIR"
sam build --use-container
#copy in the results of the build to our build directory
cp -r .aws-sam/build/DummyFunction/* $BUILD_DIR
# clean up the unnecesary files
pushd $BUILD_DIR
find . -type d -name "tests" -exec rm -rf {} +
find . -type d -name "__pycache__" -exec rm -rf {} +
find . -name \*.pyc -delete
rm {requirements.txt,unzip_requirements.py} 
zip -qr9 ../../build/${REQUIREMENTS_ZIPFILE} .
popd
echo "Finding out unpacked packages size: $(du -hs $BUILD_DIR)"
#make our zip file
pushd build
echo "Creating zip file: layer.zip"
cp ../layer/unzip_requirements.py python/
zip -r ../${FINAL_ZIPFILE} python/ ${REQUIREMENTS_ZIPFILE}
popd
# find out how large the layer zip file is
echo "Finding out zip file size: $(du -h ${FINAL_ZIPFILE})"
#clean out the build folder
rm -rf $BUILD_DIR/*
rm -rf $PACKAGE_DIR/*
# copy layer file to S3
aws s3 cp ${FINAL_ZIPFILE} s3://${S3_BUCKET}/${S3_KEY}
#publish our layer
echo "Publishing new lambda layer with name: ${LAYER_NAME}"
aws lambda publish-layer-version --layer-name ${LAYER_NAME} --content S3Bucket=${S3_BUCKET},S3Key=${S3_KEY} --compatible-runtimes $COMPATIBLE_RUNTIMES