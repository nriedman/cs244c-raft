FROM golang:1.24-alpine

RUN go install github.com/mattn/goreman@latest
RUN apk add --no-cache curl

WORKDIR /app

COPY . .

CMD ["sh"]
