# docker build -t mydid .

# 使用CUDA 11.3的基础镜像
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

# 安装Miniconda
RUN apt-get update && apt-get install -y wget && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/miniconda/bin:${PATH}"

# 创建conda环境
RUN conda create -n nerfstream python=3.10 -y
SHELL ["conda", "run", "-n", "nerfstream", "/bin/bash", "-c"]

# 安装PyTorch和其他依赖
RUN conda install pytorch==1.12.1 torchvision==0.13.1 cudatoolkit=11.3 -c pytorch -y && \
    pip install --no-cache-dir -r requirements.txt && \
#    pip install --no-cache-dir "git+https://github.com/facebookresearch/pytorch3d.git" && \
    pip install --no-cache-dir tensorflow-gpu==2.8.0 && \
    pip install --upgrade "protobuf<=3.20.1"

# 安装开发工具，例如vim
RUN apt-get install -y vim

# 将项目代码复制到容器中
COPY . /app

# 设置工作目录
WORKDIR /app

# 保持容器运行，开启bash
CMD ["conda", "run", "-n", "nerfstream", "/bin/bash"]