FROM openjdk:8-jdk
MAINTAINER alex <thick.tav@gmail.com>

ENV ANDROID_HOME /opt/android-sdk-linux
ENV ANDROID_NDK_HOME /opt/android-ndk-r17c
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
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget unzip zip libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 安装 SDK
RUN cd /opt && \
    mkdir ${ANDROID_HOME} && \
    curl -s https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip > android-sdk.zip && \
    unzip android-sdk.zip -d ${ANDROID_HOME} && \
    curl -s https://dl.google.com/android/repository/android-ndk-r17c-linux-x86_64.zip > android-ndk.zip && \
    unzip android-ndk.zip && \
    rm -f android-sdk.tgz android-ndk.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools:${ANDROID_NDK_HOME}

# 更新 SDK
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager "platform-tools" "platforms;android-26" "platforms;android-27" "platforms;android-28" "extras;android;m2repository" \
    "extras;google;google_play_services" "build-tools;27.0.2" "cmake;3.6.4111459" 

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

