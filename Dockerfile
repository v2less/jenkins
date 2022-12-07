FROM jenkins/jenkins:2.375.1-lts-jdk11

ENV DEBIAN_FRONTEND noninteractive
ENV INITRD No
# 设置updater_center地址
ENV JENKINS_UC https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates
ENV JENKINS_UC_DOWNLOAD https://mirrors.tuna.tsinghua.edu.cn/jenkins

ENV JENKINS_OPTS="-Dhudson.model.UpdateCenter.updateCenterUrl=https://mirrors.tuna.tsinghua.edu.cn/jenkins/updates/update-center.json"
ENV JAVA_OPTS="-Djava.awt.headless=true -Duser.timezone=Asia/Shanghai -Dfile.encoding=UTF-8 -Dsun.jnu.encoding=UTF-8 -Djenkins.install.runSetupWizard=false"

COPY executors.groovy /usr/share/jenkins/ref/init.groovy.d/executors.groovy
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.UpgradeWizard.state

# 安装 Jenkins 插件
COPY --chown=jenkins:jenkins plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN jenkins-plugin-cli --verbose -f /usr/share/jenkins/ref/plugins.txt

# 设置 Jenkins 默认用户名和密码
ENV JENKINS_USER admin
ENV JENKINS_PASS admin

# 设置 Jenkins 管理员邮箱地址
ENV JENKINS_EMAIL admin@example.com

# 设置 Jenkins URL
ENV JENKINS_URL http://localhost:8080

# 设置 Jenkins 工作目录
ENV JENKINS_HOME /var/jenkins_home

# 安装 常用软件
USER root
RUN sed -i "s@http://.*debian.org@http://mirrors.tuna.tsinghua.edu.cn@g" /etc/apt/sources.list
RUN apt-get update -qq && apt-get install -qqy sudo apt-transport-https ca-certificates \
       git locales curl gnupg2 software-properties-common wget unzip \
    && rm -rf /var/lib/apt/lists/*
# 允许 Jenkins 访问 Docker 守护进程
RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers
# 安装 Docker
RUN curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/debian $(lsb_release -cs) stable"
RUN apt-get update -qq && apt-get install -qqy docker-ce && rm -rf /var/lib/apt/lists/*
# 安装 Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/latest/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose
RUN usermod -aG docker jenkins
# 安装awscli
RUN cd /tmp && \
    wget -nv "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" && \
    unzip -q awscli-*.zip && \
    ./aws/install && aws --version
# 语言
RUN sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen
RUN locale-gen
ENV LANG zh_CN.UTF-8
ENV LANGUAGE zh_CN.UTF-8
ENV LC_ALL en_US.UTF-8
COPY entrypoint.sh /entrypoint.sh
COPY .gitconfig /root/.gitconfig
COPY jenkins.yaml /var/jenkins.yaml
ENV CASC_JENKINS_CONFIG=/var/jenkins.yaml
USER jenkins
CMD /bin/bash /entrypoint.sh
