FROM ubuntu:22.04

USER root

# install android
ENV ANDROID_HOME = ${HOME}/opt/android-sdk

ENV ANDROID_SDK_ROOT = $ANDROID_HOME \
    PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator

# android command line tools latest version (8.0)
ENV ANDROID_SDK_TOOLS_VERSION 9123335

RUN set -o xtrace \
    && cd /opt \
    && apt-get update \
    && apt-get install -y openjdk-11-jdk \
    && apt-get install -y sudo wget zip unzip git openssh-client curl bc software-properties-common build-essential ruby-full ruby-bundler libstdc++6 libpulse0 libglu1-mesa locales lcov libsqlite3-0 --no-install-recommends \
    && apt-get install -y libxtst6 libnss3-dev libnspr4 libxss1 libasound2 libatk-bridge2.0-0 libgtk-3-0 libgdk-pixbuf2.0-0 \
    && rm -rf /var/lib/apt/lists/* \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS_VERSION}_latest.zip -O android-sdk-tools.zip --no-check-certificate \
    && mkdir -p ${ANDROID_HOME}/cmdline-tools/ \
    ### 여기서 오류 남
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools/ \
    ###
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && chown -R root:root $ANDROID_HOME \
    && rm android-sdk-tools.zip \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && yes | sdkmanager --licenses \

ENV ANDROID_PLATFORM_VERSION 30
ENV ANDROID_BUILD_TOOLS_VERSION 30.0.2

RUN yes | sdkmanager \
    "platforms;android-$ANDROID_PLATFORM_VERSION" \
    "build-tools;$ANDROID_BUILD_TOOLS_VERSION"


# install flutter
ENV FLUTTER_HOME=${HOME}/opt/flutter \
    FLUTTER_VERSION=stable
ENV FLUTTER_ROOT=$FLUTTER_HOME

ENV PATH ${PATH}:${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin

# shallow clone of currently stable channel
RUN git clone --depth 1 --branch ${FLUTTER_VERSION} https://github.com/flutter/flutter.git ${FLUTTER_HOME}

RUN yes | flutter doctor --android-licenses \
    && flutter doctor \
    && chown -R root:root ${FLUTTER_HOME}

RUN flutter precache


# install gradle
ENV GRADLE_HOME=/opt/gradle/gradle-6.7.1
ENV PATH ${PATH}:${GRADLE_HOME}/bin

RUN wget https://services.gradle.org/distributions/gradle-6.7.1-bin.zip -P /tmp --no-check-certificate
RUN sudo unzip -d /opt/gradle /tmp/gradle-6.7.1-bin.zip \
    && rm /tmp/gradle-6.7.1-bin.zip
