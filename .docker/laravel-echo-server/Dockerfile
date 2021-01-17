FROM node:14-alpine

LABEL maintainer="Mai Trung Duc (maitrungduc1410@gmail.com)"

WORKDIR /app

RUN npm install -g pm2 laravel-echo-server

# ==== LOCAL
# group "dialout" has ID = 20
RUN adduser -D -u 501 appuser -G dialout

RUN chown -R appuser:dialout /app

COPY --chown=appuser:dialout . .

USER appuser
# ==== PRODUCTION
# COPY --chown=node:node . .

# USER node
# ====

EXPOSE 6001

# log rotate must be run after we switch user
RUN pm2 install pm2-logrotate

CMD ["pm2-runtime", "echo.json"]
