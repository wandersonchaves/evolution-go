FROM golang:1.24-alpine AS build

# Build-base é essencial para CGO (utilizado pela whatsmeow para crypto)
RUN apk update && apk add --no-cache \
    git \
    build-base \
    tzdata \
    ffmpeg \
    libjpeg-turbo-dev \
    libwebp-dev \
    ca-certificates \
    postgresql-dev

WORKDIR /build

# Copia tudo para o contexto de build
COPY . .

# Validação: Se falhar aqui, o passo 1 (acima) não foi executado corretamente no seu Git
RUN if [ ! -f "./whatsmeow-lib/go.mod" ]; then \
    echo "ERRO CRÍTICO: whatsmeow-lib/go.mod não encontrado no contexto de build!"; \
    ls -la; \
    exit 1; \
fi

# Instala dependências
RUN go mod download

# Build com CGO habilitado
ARG VERSION=dev
RUN CGO_ENABLED=1 go build -ldflags "-X main.version=${VERSION}" -o server ./cmd/evolution-go

FROM alpine:3.19 AS final

RUN apk update && apk add --no-cache \
    tzdata \
    ffmpeg \
    libjpeg-turbo \
    libwebp \
    ca-certificates \
    libpq

WORKDIR /app

# Copia o binário e os arquivos do Manager (Interface da Evolution)
COPY --from=build /build/server .
COPY --from=build /build/VERSION ./VERSION
# O copy com wildcard evita erro caso a pasta manager/dist não exista na build
COPY --from=build /build/manager/dist* ./manager/dist/

ENV TZ=America/Sao_Paulo
EXPOSE 8080

ENTRYPOINT ["/app/server"]