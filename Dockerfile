# Estágio de Build
FROM golang:1.24-alpine AS build

# Dependências nativas para CGO e compilação da Evolution
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

# Copia tudo (Assumindo que você seguiu a Solução 2 e a pasta agora está no Git)
COPY . .

# Validação crítica para o log do Railway
RUN if [ ! -f "./whatsmeow-lib/go.mod" ]; then echo "ERRO: whatsmeow-lib não encontrada no repositório!"; exit 1; fi

# Download das dependências
RUN go mod download

# Build do binário
ARG VERSION=dev
RUN CGO_ENABLED=1 go build -ldflags "-X main.version=${VERSION}" -o server ./cmd/evolution-go

# Estágio Final (Runtime)
FROM alpine:3.19 AS final

RUN apk update && apk add --no-cache \
    tzdata \
    ffmpeg \
    libjpeg-turbo \
    libwebp \
    ca-certificates \
    libpq

WORKDIR /app

# Copia o binário e assets necessários
COPY --from=build /build/server .
COPY --from=build /build/VERSION ./VERSION
# O manager pode não existir se não for buildado antes, tratamos com condicional
COPY --from=build /build/manager/dist* ./manager/dist/

ENV TZ=America/Sao_Paulo
EXPOSE 8080

ENTRYPOINT ["/app/server"]