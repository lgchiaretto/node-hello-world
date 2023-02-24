FROM node:16.19-alpine as builder
ENV HOME=/app
WORKDIR $HOME/
RUN apk add --no-cache python3 make gcc g++ tzdata
COPY package.json $HOME/
RUN npm install
COPY . $HOME/
#RUN npm run build
RUN rm -fr $HOME/src
RUN npm prune --production
# --------------------------------------------------------------------
FROM node:16.19-alpine as runner
# Build arguments to change source url, branch or tag
ARG UID=10000
ARG PORT=2650
ENV HOME=/app
WORKDIR $HOME/
RUN apk add --no-cache tzdata
# configure timestamp for brasil
COPY --from=builder /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
COPY --from=builder $HOME/node_modules $HOME/node_modules
COPY --from=builder $HOME/dist $HOME/dist
COPY . $HOME/
# Set some default config variables
ENV NODE_ENV=production
ENV PORT=$PORT
RUN adduser -u $UID -h $HOME/ -D -S app && \
    chown -R app $HOME/
EXPOSE $PORT
CMD ["npm", "start"]