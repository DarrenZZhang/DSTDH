#!/bin/bash

#set -x
set -e

if [ $# -ne 2 ] ; then
    echo 'Please input parameters ROOT_FOLDER and GPU_ID'
    exit 1;
fi

CAFFE_ROOT=/home/zl/caffe
ROOT_FOLDER=$1  # image root folder
GPU_ID=$2
export PATH=$PATH:/usr/local/MATLAB/R2016b/bin

# prepare  sudo ./train32.sh ./flickr_25 1

# parameters set
alpha=1e-2
beta=1e-3
nu=0.001
nAnchorA=100
nAnchorH=500
mu=1e-2
pho=1.1
sA=2
sigmaA=0
sigmaH=40

##########################################
# prepare
binarytestPath="./analysis/32/binary-test.mat"
if [ ! -f "$binarytestPath" ]; then
    echo 'binarytestPath OK!'
else
    rm -r ./analysis/32/binary-test.mat
    echo 'binarytestPath Delete!'    
fi

binarytraintPath="./analysis/32/binary-train.mat"
if [ ! -f "$binarytraintPath" ]; then
    echo 'binarytraintPath OK!'
else
    rm -r ./analysis/32/binary-train.mat
    echo 'binarytraintPath Delete!'
fi

feattraintPath="./analysis/32/feat-train.mat"
if [ ! -f "$feattraintPath" ]; then
    echo 'feattraintPath OK!'
else
    rm -r ./analysis/32/feat-train.mat
    echo 'feattraintPath Delete!'
fi

feattestPath="./analysis/32/feat-test.mat"
if [ ! -f "$feattestPath" ]; then
    echo 'feattestPath OK!'
else
    rm -r ./analysis/32/feat-test.mat
    echo 'feattestPath Delete!'
fi

B32="./data_from_STDH/B_32bits.h5"
if [ ! -f "$B32" ]; then
    echo 'B32 OK!'
else
    rm -r ./data_from_STDH/B_32bits.h5
    echo 'B32 Delete!'
fi

echo "2.STDH algorithm"
cd STDH
matlab -nojvm -nodesktop -r "alpha=$alpha,beta=$beta,nAnchorA=$nAnchorA,nAnchorH=$nAnchorH,sA=$sA,sigmaA=$sigmaA,sigmaH=$sigmaH,mu=$mu,pho=$pho,nu=$nu;run STDH_32.m; quit;"
echo "generate .h5 file -> ./data_from_STDH/B_32bits.h5"
cd ..

echo "3.finetune VGG model to initialize W."
cd finetune_network
$CAFFE_ROOT/build/tools/caffe train -solver ./solver_32bits.prototxt -weights ../caffemodels/VGG_ILSVRC_16_layers.caffemodel -gpu $GPU_ID
cd ..
echo "finetuning finished!"

echo "4.test"
matlab -nojvm -nodesktop -r "run ./run_flickr25_32bits.m; quit;"
echo "test1 finished!"