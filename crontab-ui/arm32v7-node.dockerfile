# arm dockerfile for crontab-ui
FROM arm32v7/node:8-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get upgrade -y && \
DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl cron  && \
apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /home/node

USER node

ENV NPM_CONFIG_PREFIX=/home/node/.npm-global
ENV PATH=$PATH:/home/node/.npm-global/bin

RUN npm install -g crontab-ui && \
npm install -g pm2

ENV PORT 8000

EXPOSE $PORT

CMD [ "pm2-runtime", "crontab-ui", "--raw", "start" ]
# --raw or --json format