FROM continuumio/anaconda3

RUN conda install xeus-cling -c conda-forge
RUN conda install pytorch torchvision -c pytorch
RUN conda install -c conda-forge jupyterlab notebook