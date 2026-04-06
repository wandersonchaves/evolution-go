FROM golang:1.25.0-alpine AS build

RUN apk update && apk add --no-cache tzdata ffmpeg libjpeg-turbo libwebp ca-certificates

WORKDIR /build

# Copiar apenas arquivos de dependências primeiro para cachear o download
COPY go.mod go.sum ./

# Copiar whatsmeow-lib que é uma dependência local
COPY whatsmeow-lib/ ./whatsmeow-lib/

# Agora fazer download das dependências (com replace funcionando)
RUN go mod download

# Copiar o restante do código
COPY . .

ARG VERSION=dev
RUN CGO_ENABLED=1 go build -ldflags "-X main.version=${VERSION}" -o server ./cmd/evolution-go

FROM alpine:3.19.1 AS final

RUN apk update && apk add --no-cache tzdata ffmpeg libjpeg-turbo libwebp

WORKDIR /app

RUN mkdir -p /app/manager/dist

COPY --from=build /build/server .
COPY --from=build /build/manager/dist ./manager/dist
COPY --from=build /build/VERSION ./VERSION

ENV TZ=America/Sao_Paulo

EXPOSE 8080

ENTRYPOINT ["/app/server"]
