FROM python:3.10-alpine

# Get latest root certificates
RUN apk add --no-cache ca-certificates tzdata && update-ca-certificates
# Install build dependencies for cffi
RUN apk add --no-cache gcc musl-dev libffi-dev
# Install the required packages
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# PYTHONUNBUFFERED: Force stdin, stdout and stderr to be totally unbuffered. (equivalent to `python -u`)
# PYTHONHASHSEED: Enable hash randomization (equivalent to `python -R`)
# PYTHONDONTWRITEBYTECODE: Do not write byte files to disk, since we maintain it as readonly. (equivalent to `python -B`)
ENV PYTHONUNBUFFERED=1 PYTHONHASHSEED=random PYTHONDONTWRITEBYTECODE=1

# Default port for Flower
EXPOSE 5555

ENV APP_DIR /app
ENV PYTHONPATH ${APP_DIR}

WORKDIR $APP_DIR

COPY . .
COPY .env .

RUN addgroup -g 1000 flower \
    && adduser -u 1000 -G flower -D flower \
    && chown -R flower:flower $APP_DIR

USER flower
