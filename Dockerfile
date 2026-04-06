FROM golang:1.25.0-alpine AS build

# Instalação de dependências de compilação (CGO requer build-base)
RUN apk update && apk add --no-cache \
    git \
    build-base \
    tzdata \
    ffmpeg \
    libjpeg-turbo-dev \
    libwebp-dev \
    ca-certificates

WORKDIR /build

# Em vez de copiar picado, copiamos o contexto inteiro para garantir o replace
# O .dockerignore deve estar configurado para não subir lixo
COPY . .

# Agora forçamos o tidy e o download com o contexto local já presente
RUN go mod tidy
RUN go mod download

ARG VERSION=dev
# Compilação com CGO habilitado para suporte a processamento de imagem/video
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
