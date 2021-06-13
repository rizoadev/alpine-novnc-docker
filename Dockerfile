FROM node:alpine

RUN \
    # Install required packages
    echo "http://dl-3.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update --upgrade add \
    bash \
    fluxbox \
    git \
    supervisor \
    xvfb \
    x11vnc \
    && \
    # Install noVNC
    git clone --depth 1 https://github.com/novnc/noVNC.git /root/noVNC && \
    git clone --depth 1 https://github.com/novnc/websockify /root/noVNC/utils/websockify && \
    rm -rf /root/noVNC/.git && \
    rm -rf /root/noVNC/utils/websockify/.git && \
    apk del git && \
    sed -i -- "s/ps -p/ps -o pid | grep/g" /root/noVNC/utils/launch.sh


ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD 1
ENV PUPPETEER_EXECUTABLE_PATH /usr/bin/chromium-browser
WORKDIR /app
# COPY --chown=chrome package.json package-lock.json ./
COPY package.json package-lock.json ./
RUN npm install
# COPY --chown=chrome . ./
COPY . ./

# Cd into /app
WORKDIR /app

# Copy package.json into app folder
COPY package.json /app

# Install dependencies
RUN npm install
COPY . /app
RUN apk add chromium
# Start server on port 3000∂
EXPOSE 3000:3001
ENV PORT=3001

# Creating Display
ENV DISPLAY :99

# Start script on Xvfb
CMD Xvfb :99 -screen 0 1024x768x16 & npm start