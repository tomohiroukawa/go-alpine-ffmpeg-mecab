FROM golang:alpine3.18

# Install packages, mecab, ipadic, neologd
WORKDIR /local

# Copy mecab & ipadic
COPY ./mecab-0.996.tar.gz .

RUN apk add \
    ffmpeg-dev \
    ffmpeg \
    ca-certificates \
    tzdata \
    bash \
    gcc \
    curl \
    build-base \
    git \
    openssl \
    && \
    tar -zxf mecab-0.996.tar.gz && \
    cd /local/mecab-0.996 && \
    ./configure --enable-utf8-only --with-charset=utf8 && \
    make && \
    make check && \
    make install  \
    && \
    cd /local && \
    curl -o mecab-ipadic-2.7.0-20070801.tar.gz -OL "https://sourceforge.net/projects/mecab/files/mecab-ipadic/2.7.0-20070801/mecab-ipadic-2.7.0-20070801.tar.gz/download?use_mirror=autoselect" && \
    tar zxf mecab-ipadic-2.7.0-20070801.tar.gz && \
    cd mecab-ipadic-2.7.0-20070801 && \
    ./configure --with-charset=utf8 && \
    make && \
    make install && \
    cd /local && \
    git clone --depth 1 https://github.com/tomohiroukawa/mecab-ipadic-neologd.git  && \
    ./mecab-ipadic-neologd/bin/install-mecab-ipadic-neologd -n -y \
    && \
    rm -fr /local && \
    apk del git curl && \
    rm -fr /tmp/src && \
    rm -fr /var/cache/apk

## Install cabocha
#WORKDIR /local
#ENV CPPFLAGS -I/usr/local/include
#RUN curl -c  cabocha-0.69.tar.bz2 -s -L "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU" | grep confirm |  sed -e "s/^.*confirm=\(.*\)&amp;id=.*$/\1/" | xargs -I{} \
#    curl -b  cabocha-0.69.tar.bz2 -L -o cabocha-0.69.tar.bz2 "https://drive.google.com/uc?confirm={}&export=download&id=0B4y35FiV1wh7SDd1Q1dUQkZQaUU" && \
#tar -jxf cabocha-0.69.tar.bz2

#WORKDIR cabocha-0.69
#RUN ./configure --prefix=/usr/local --with-charset=utf8 && \
#make && \
#make install

# set mecab env vars
ENV CGO_LDFLAGS="-L/usr/local/lib -lmecab -lstdc++"
ENV CGO_CFLAGS="-I/usr/local/include"
ENV GOPROXY=https://proxy.golang.org
