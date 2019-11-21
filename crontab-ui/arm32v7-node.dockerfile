# arm dockerfile for crontab-ui
FROM arm32v7/node:8-slim

RUN DEBIAN_FRONTEND=noninteractive apt-get update -y && apt-get upgrade -y && \
DEBIAN_FRONTEND=noninteractive apt-get install -y wget curl cron  && \
apt-get clean && rm -rf /var/lib/apt/lists/*

USER node

RUN npm install -g crontab-ui && \
npm install -g pm2

ENV PORT 8000

EXPOSE $PORT

CMD [ "pm2-runtime", "crontab-ui", "--raw", "start" ]
# --raw or --json format