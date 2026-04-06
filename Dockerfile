FROM golang:1.25.0-alpine AS build

# Instalação de dependências de compilação
RUN apk update && apk add --no-cache \
    git \
    build-base \
    tzdata \
    ffmpeg \
    libjpeg-turbo-dev \
    libwebp-dev \
    ca-certificates

WORKDIR /build

# Passo 1: Copiar explicitamente a biblioteca local antes de tudo
# Isso garante que mesmo que o COPY . . falhe por algum motivo de ignore,
# esta pasta será enviada.
COPY whatsmeow-lib/ ./whatsmeow-lib/

# Passo 2: Validar se o arquivo existe (Isso fará o build falhar aqui com um erro claro se a pasta estiver vazia)
RUN ls -l ./whatsmeow-lib/go.mod

# Passo 3: Copiar o restante dos arquivos
COPY . .

# Passo 4: Configurar o Go
# Removemos o 'go mod tidy' temporariamente para usar o 'download' direto, 
# pois o tidy tenta baixar tudo de novo e pode se perder com o replace local.
RUN go mod download

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
