FROM node:18-alpine

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install --production

COPY . .

COPY .env .  

ENV NODE_ENV=production

EXPOSE 5000

CMD ["node", "server.js"]
