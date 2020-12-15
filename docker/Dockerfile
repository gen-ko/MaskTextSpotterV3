FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive
ARG PYTHON_VERSION=3.7.9

#ARG PYTHON_BUILD_ENABLE_OPTIMIZATIONS="--enable-optimizations"
ARG PYTHON_BUILD_ENABLE_OPTIMIZATIONS=""

RUN apt-get update && \
    apt-get install -y \
	apt-utils ca-certificates git wget sudo \
	cmake ninja-build protobuf-compiler libprotobuf-dev \
    gcc g++ git make libglib2.0-0 libsm6 libxext6 libxrender-dev \
    libffi-dev libde265-dev libx265-dev x265 \
    libgl1-mesa-glx libsqlite3-dev \
    automake gettext libtool autoconf build-essential pkg-config \
    libcppunit-dev libarchive-dev libssl-dev liblzma-dev && \
    cd /opt && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --with-openssl=/usr ${PYTHON_BUILD_ENABLE_OPTIMIZATIONS} && \
    make -j`nproc` && make -j`nproc` install && \
    cd /opt && rm -rf Python-${PYTHON_VERSION} && rm -rf Python-${PYTHON_VERSION}.tgz && \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/python3 /usr/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip && \
    ln -sf /usr/local/bin/pip3 /usr/bin/pip && \
    pip install --upgrade pip && \
    rm -rf /var/lib/apt/lists/*

# OpenSSL
#    cd /opt && \
#    wget https://www.openssl.org/source/openssl-1.1.1g.tar.gz && \
#    tar tar xzf openssl-1.1.1g.tar.gz && \
#    cd openssl-1.1.1g && \
#    ./config shared --prefix=/usr/local && \
#    make -j`nproc` install && \
#    cd /opt && rm -rf openssl-1.1.1g.tar.gz && rm -rf openssl-1.1.1g && \

# libheif
RUN cd /opt && \
    git clone --single-branch --branch release-1.4 https://github.com/strukturag/libheif.git libheif && \
    cd /opt/libheif && \
    git checkout f22f9a62e6063237db182e5064f83be92f156b85 && \
    ./autogen.sh && \
    ./configure && \
    make -j`nproc` && \
    make -j`nproc` install && \
    ldconfig && \
    rm -rf /opt/libheif

# set FORCE_CUDA because during `docker build` cuda is not accessible
ENV FORCE_CUDA="1"
# This will by default build detectron2 for all common cuda architectures and take a lot more time,
# because inside `docker build`, there is no way to tell which architecture will be used.
ARG TORCH_CUDA_ARCH_LIST="Kepler;Maxwell;Pascal;Volta;Turing"
ENV TORCH_CUDA_ARCH_LIST="${TORCH_CUDA_ARCH_LIST}"
RUN pip install torch===1.7.1 torchvision===0.8.2 torchaudio===0.7.2 -f https://download.pytorch.org/whl/torch_stable.htm
#RUN pip install torch==1.7.0+cu110 torchvision==0.8.1+cu110 torchaudio===0.7.0 -f https://download.pytorch.org/whl/torch_stable.html
RUN pip install 'pycocotools>=2.0.1' tensorboard opencv-python numpy scipy matplotlib ipython jupyter pandas sympy nose Shapely \
                editdistance pyclipper scikit-image \
                Polygon3 'json-tricks>=3.15.3' cython ninja yacs tqdm \
                scikit-learn jupyterlab \
                easydict

# nvidia-DALI, for cuda 10.0, 10.1, 10.2
RUN pip install --extra-index-url https://developer.download.nvidia.com/compute/redist nvidia-dali-cuda100

# pyheif, only possible when libheif is installed
RUN pip install 'git+https://github.com/david-poirier-csn/pyheif.git@8d03e0bf6dde6aa0317471792d698a30502f9e1d'

# fvcore, needed by detectron2.
ENV FVCORE_CACHE="/tmp/.torch/fvcore_cache"
RUN pip install 'git+https://github.com/facebookresearch/fvcore' && \
    mkdir -p ${FVCORE_CACHE} && \
    chmod a+rwx ${FVCORE_CACHE}

# build detectron2 from source
RUN cd /opt && \
    git clone https://github.com/facebookresearch/detectron2 && \
    cd detectron2 && \
    python -m pip install . && \
    rm -rf /opt/detectron2

# matplotlib config dir
ENV MPLCONFIGDIR="/tmp/.config/matplotlib"
RUN mkdir -p ${MPLCONFIGDIR} && \
    chmod a+rwx ${MPLCONFIGDIR}

# AmbaJson
ARG SSH_PRIVATE_KEY
ARG SSH_PORT=2222
RUN mkdir -p /root/.ssh && touch /root/.ssh/known_hosts && \
ssh-keyscan -p ${SSH_PORT} algoapp.ambarella.com >> /root/.ssh/known_hosts && \
echo "${SSH_PRIVATE_KEY}" >> /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa && \
pip install "git+ssh://algoapp.ambarella.com:${SSH_PORT}/jli/AmbaJson.git" && \
rm /root/.ssh/id_rsa && rm /root/.ssh/known_hosts

# MaskTextSpotterV3
RUN mkdir /workspace
COPY . /workspace/MaskTextSpotterV3
WORKDIR /workspace/MaskTextSpotterV3
RUN python -m pip install -e .
