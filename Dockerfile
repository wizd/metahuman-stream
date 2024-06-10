# docker build -t mydid .

# 使用CUDA 11.3的基础镜像
FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu20.04

ENV TZ='Asia/Shanghai'
ENV DEBIAN_FRONTEND=noninteractive

# 安装Miniconda
RUN apt-get update && apt-get install -y wget git vim libgl1-mesa-glx libglib2.0-0 net-tools iputils-ping curl && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /miniconda && \
    rm Miniconda3-latest-Linux-x86_64.sh

ENV PATH="/miniconda/bin:${PATH}"

# 创建conda环境
RUN conda create -n nerfstream python=3.10 -y
SHELL ["conda", "run", "-n", "nerfstream", "/bin/bash", "-c"]

# 将项目代码复制到容器中
COPY . /app

# 设置工作目录
WORKDIR /app

# 安装PyTorch
RUN conda install pytorch==1.12.1 torchvision==0.13.1 cudatoolkit=11.3 -c pytorch -y

# 安装其他Python依赖
RUN pip install --no-cache-dir -r requirements.txt

# 安装TensorFlow GPU
RUN pip install --no-cache-dir tensorflow-gpu==2.8.0

# 更新protobuf版本
RUN pip install --upgrade "protobuf<=3.20.1"

# 在/root/.bashrc中添加conda初始化
RUN echo "source /miniconda/etc/profile.d/conda.sh" >> /root/.bashrc && \
    echo "conda activate nerfstream" >> /root/.bashrc

    # 安装PyTorch3D
RUN conda run -n nerfstream /bin/bash -c "cd ~/ && \
    git clone https://github.com/facebookresearch/pytorch3d.git && \
    cd pytorch3d && \
    python setup.py install"

# 修改flask_sockets.py文件
RUN sed -i 's/self.url_map.add(Rule(rule, endpoint=f))/self.url_map.add(Rule(rule, endpoint=f, websocket=True))/' /miniconda/envs/nerfstream/lib/python3.10/site-packages/flask_sockets.py

# 保持容器运行，运行app.py
CMD ["conda", "run", "-n", "nerfstream", "python", "app.py"]