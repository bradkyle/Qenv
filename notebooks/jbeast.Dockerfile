FROM continuumio/anaconda3
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
         g++ \
         make \
         cmake \
         wget \
         unzip \
         vim \
         git \
         libopencv-dev \
         libboost-all-dev \
         python3 \
         python3-pip
 
RUN conda install pytorch-cpu torchvision-cpu -c pytorch
RUN conda install -c conda-forge jupyterlab notebook
RUN conda install xeus-cling -c conda-forge