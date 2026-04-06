# Alterado para 1.25 para satisfazer a restrição do go.mod
FROM golang:1.25-alpine AS build

# Configuração para garantir que o Go use a versão correta se necessário
ENV GOTOOLCHAIN=auto

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

# O COPY . . agora deve funcionar pois você já resolveu o problema da whatsmeow-lib
COPY . .

# Validação de segurança
RUN if [ ! -f "./whatsmeow-lib/go.mod" ]; then \
    echo "ERRO: whatsmeow-lib não encontrada!"; \
    exit 1; \
fi

# Instala dependências (Agora com a versão de Go correta)
RUN go mod download

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

COPY --from=build /build/server .
COPY --from=build /build/VERSION ./VERSION
# O manager/dist pode ser opcional dependendo do seu gitignore
COPY --from=build /build/manager/dist* ./manager/dist/

ENV TZ=America/Sao_Paulo
EXPOSE 8080

ENTRYPOINT ["/app/server"]