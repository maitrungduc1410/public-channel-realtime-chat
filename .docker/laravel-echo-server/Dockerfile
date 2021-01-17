FROM node:14-alpine

LABEL maintainer="Mai Trung Duc (maitrungduc1410@gmail.com)"

WORKDIR /app

RUN npm install -g pm2 laravel-echo-server

RUN adduser -D -u 501 appuser -G dialout

RUN chown -R appuser:dialout /app

COPY --chown=appuser:dialout . .

# COPY --chown=node:node . .

EXPOSE 6001

USER appuser

# USER node

# log rotate must be run after we switch user
RUN pm2 install pm2-logrotate

CMD ["pm2-runtime", "echo.json"]
