FROM ubuntu:18.04
RUN apt-get -q update \
 && apt-get install -q -y --no-install-recommends \
        wget \
        unzip \
        imagemagick \
        python2.7 \
        python-pip \
        openjdk-8-jre-headless \
        libreoffice \
        ghostscript

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip && pip install opf-fido

RUN wget -q -O droid.zip "http://www.nationalarchives.gov.uk/documents/information-management/droid-binary-6.4-bin.zip" \
 && mkdir -p /opt/droid \
 && unzip -d /opt/droid droid.zip \
 && chmod 755 /opt/droid/droid.sh \
 && rm droid.zip

RUN wget -q -O fop.tar.gz "http://www.apache.org/dyn/closer.cgi?filename=/xmlgraphics/fop/binaries/fop-2.3-bin.tar.gz&action=download" \
 && mkdir -p /opt/fop \
 && tar xzf fop.tar.gz -C /opt/fop --strip-components=2 \
 && rm fop.tar.gz

RUN echo "8\n9\n" | apt-get install tzdata
RUN mkdir -p /teneo/format/spec
ADD ./tools /teneo/format/tools
ADD ./data /teneo/format/data
ADD ./spec/data /teneo/format/spec/data
ADD ./base/rework_path /teneo/format/rework_path
CMD /bin/bash