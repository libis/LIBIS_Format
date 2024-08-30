# Build arguments
ARG BASE_IMAGE_VERSION=latest
ARG USER_NAME=app
ARG USER_ID=5000
ARG APP_DIR=/app
ARG HOME_DIR=/home/app
ARG TZ=Europe/Brussels

FROM registry.docker.libis.be/teneo/ruby-base:${BASE_IMAGE_VERSION}

# Install required packages
RUN apt-get update -qq \
 && apt-get -qqy upgrade \
 && apt-get install -qqy --no-install-recommends \
      file \
      poppler-utils \
      libchromaprint-dev sox libsox-fmt-all \
      wkhtmltopdf \
      ffmpeg \
      libreoffice \
      imagemagick \
      ghostscript \
      gsfonts \
      fonts-liberation \
      python3 python3-setuptools python3-wheel python3-pip \
      unzip \
      default-jre \
      libreoffice-java-common \
      apt-transport-https software-properties-common \
 && wget -q http://www.mirbsd.org/~tg/Debs/sources.txt/wtf-bookworm.sources \
 && mkdir -p /etc/apt/sources.list.d \
 && mv wtf-bookworm.sources /etc/apt/sources.list.d/ \
 && apt update \
 && apt install -qqy --no-install-recommends openjdk-8-jdk \
 && apt-get clean \
 && rm -fr /var/cache/apt/archives/* \
 && rm -fr /var/lib/apt/lists/* /tmp/* /var/tmp* \
 && truncate -s 0 /var/log/*log \
 && fc-cache

# Install fido
ARG FIDO_VERSION=1.6.1
RUN wget -q https://github.com/openpreserve/fido/archive/refs/tags/v${FIDO_VERSION}.zip \
  && unzip v${FIDO_VERSION}.zip \
  && cd fido-${FIDO_VERSION} \
  && python3 setup.py install --quiet \
  && cd .. \
  && rm -fr fido-${FIDO_VERSION}

# Install droid
ARG DROID_VERSION=6.8.0
RUN wget -q https://github.com/digital-preservation/droid/releases/download/droid-${DROID_VERSION}/droid-binary-${DROID_VERSION}-bin.zip \
  && unzip -qd /opt/droid droid-binary-${DROID_VERSION}-bin.zip \
    && chmod 755 /opt/droid/droid.sh \
    && rm droid-binary-${DROID_VERSION}-bin.zip

# Set timezone
ARG TZ
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN gem install bundler

# Create application user
ARG USER_NAME
ARG USER_ID
ARG APP_DIR
ARG HOME_DIR
RUN useradd -m -d ${HOME_DIR} -l -u ${USER_ID} -g 0 -K UMASK=002 ${USER_NAME}
ENV HOME=${HOME_DIR}

# Switch to application user 
USER ${USER_NAME}

# Configure umask and file permissions
RUN umask 0002 \
 && echo "umask 0002" >> ${HOME_DIR}/.profile \
 && find ${HOME_DIR} -exec chmod -c g+w {} \;

# Switch to application dir
WORKDIR ${APP_DIR}

# Settings required by wkhtlmtopdf (QT)
ENV XDG_RUNTIME_DIR=./spec/work/tmp
RUN mkdir -p ${XDG_RUNTIME_DIR}

# Configure bundler
RUN bundle config set --local clean 'true' \
 && bundle config set --local deployment 'true' \
 && bundle config set --local frozen 'true' \
 && bundle config set --local disable_version_check 'true' \
 && bundle config set --local path 'vendor/bundle'

# Start the tests
CMD ["rake"]
