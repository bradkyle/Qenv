FROM gzupark/jupyterlab:bionic-gpu-py3

RUN apt-get update

# Install packages
RUN curl -sSL https://raw.githubusercontent.com/gzupark/jupyterlab-docker/master/assets/requirements-ml.txt -o requirements.txt
RUN /bin/bash -c "source ~/.bashrc && pip --no-cache-dir install -r requirements.txt"
RUN rm requirements.txt

# Install deep learning packages
RUN /bin/bash -c "source ~/.bashrc && \
    pip --no-cache-dir install tensorflow-gpu keras"
RUN /bin/bash -c "source ~/.bashrc && \
    conda install -y pytorch torchvision cudatoolkit -c pytorch"

# Install jupyterlab tensorboard
RUN /bin/bash -c "source ~/.bashrc && \
    pip --no-cache-dir install -U tensorboard jupyter-tensorboard && \
    jupyter labextension install jupyterlab_tensorboard"

# Install jupyter and notebook extension
RUN /bin/bash -c "source ~/.bashrc && conda install -q -y jupyter ipywidgets~=7.4.2 && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter notebook --generate-config"

# Install jupyterlab
RUN /bin/bash -c "source ~/.bashrc && conda install -q -y jupyterlab~=0.35.5 && jupyter serverextension enable --py jupyterlab"

# Install git extension on jupyterlab
RUN /bin/bash -c "source ~/.bashrc && conda install -q -y nodejs~=10.13.0 && \
    jupyter labextension install @jupyterlab/git && \
    pip --no-cache-dir install jupyterlab-git~=0.6.1 && \
    jupyter serverextension enable --py jupyterlab_git"

# Install github extension on jupyterlab
RUN /bin/bash -c "source ~/.bashrc && \
    jupyter labextension install @jupyterlab/github && \
    pip --no-cache-dir install jupyterlab_github~=0.7.0 && \
    jupyter serverextension enable --sys-prefix jupyterlab_github"

# Install jupyter and notebook extension
RUN /bin/bash -c "source ~/.bashrc && conda install -q -y jupyter ipywidgets~=7.4.2 && \
    jupyter nbextension enable --py widgetsnbextension && \
    jupyter notebook --generate-config"

# Clean up
RUN apt-get update && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN conda clean --all --yes

# Expose port & cmd
EXPOSE 8888

CMD /bin/bash -c "source ~/.bashrc && jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir=/workspace --allow-root"