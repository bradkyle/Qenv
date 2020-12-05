FROM gcr.io/deeplearning-platform-release/pytorch-gpu as base

RUN pip install --upgrade gym gym[atari] paddlepaddle parl qpython

RUN mkdir -p /home/impala
ADD . . 

FROM base as run
WORKDIR /home/impala
