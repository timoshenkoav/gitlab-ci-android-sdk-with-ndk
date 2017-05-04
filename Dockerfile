FROM ubuntu:15.04
MAINTAINER alex <thick.tav@gmail.com>

ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_NDK_HOME /opt/android-ndk-r13b
ENV GRADLE_USER_HOME /opt/gradle

# 更换 Ubuntu 镜像更新地址
#RUN echo "deb http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse\n\
#deb http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse\n\
#deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse\n\
#deb http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse\n\
#deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse\n\
#deb-src http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse\n\
#deb-src http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse\n\
#deb-src http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse\n\
#deb-src http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse\n\
#deb-src http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse" > /etc/apt/sources.list

# 安装基础包
RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget unzip openjdk-7-jdk openjdk-8-jdk libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 安装 SDK
RUN cd /opt && \
    curl -s https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz > android-sdk.tgz && \
    tar -xvzf android-sdk.tgz && \
    curl -s https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip > android-ndk.zip && \
    unzip android-ndk.zip && \
    rm -f android-sdk.tgz android-ndk.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}

# 更新 SDK
RUN echo y | android update sdk --no-ui --all --filter \
  build-tools-25.0.2

RUN echo y | android update sdk --no-ui --all --filter \
  android-25

RUN echo y | android update sdk --no-ui --all --filter \
  addon-google_apis-google-24

RUN echo y | android update sdk --no-ui --all --filter \
  platform-tools,extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository

# 安装 gradle
COPY gradle/ /opt/

# gradlew 版本列表
#   https://services.gradle.org/distributions/
# android-tools 版本列表
#   https://bintray.com/android/android-tools/com.android.tools.build.gradle#files/com/android/tools/build/gradle
RUN cd /opt && \
    chmod +x gradlew && \
    bash ./gradle_install.sh 3.3 && \
    bash ./gradle_plugin.sh 2.3.1 && \
    rm -rf gradle_install.sh gradle_plugin.sh build.gradle gradlew gradle/wrapper/gradle-wrapper.{jar,properties}
RUN wget "https://www.dropbox.com/s/q88bhd199zbjc69/licenses.zip?dl=1" -O ${ANDROID_HOME}/license.zip    
RUN cd ${ANDROID_HOME} && unzip -q -u license.zip

