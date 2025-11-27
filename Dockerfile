FROM python:3.7-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    make \
    python3-dev \
    libxml2-dev \
    libxslt1-dev \
    libpq-dev \
    libjpeg-dev \
    libpng-dev \
    zlib1g-dev \
    python3 \
    libssl-dev \
    libffi-dev \
    redis-tools \
    libgdk-pixbuf2.0-0 \
    libldap2-dev \
    libsasl2-dev \
    libmagic1 \
    netcat-traditional \
    && rm -rf /var/lib/apt/lists/* /var/lib/dpkg/* /var/cache/* /var/log/*

# Create non-root user
RUN groupadd -r faraday && useradd -r -g faraday faraday

# Set build working directory
WORKDIR /src

# Copy application code
COPY . /src

# Install Python dependencies
RUN pip install -U pip --no-cache-dir \
    && pip install -e . --no-cache-dir

# Copy entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set runtime working directory
WORKDIR /home/faraday

# Create necessary directories
RUN mkdir -p /home/faraday/.faraday/config \
    /home/faraday/.faraday/logs \
    /home/faraday/.faraday/session \
    /home/faraday/.faraday/storage \
    && chown -R faraday:faraday /home/faraday

# Switch to non-root user
USER faraday

# Expose application port
EXPOSE 5985

# Set entrypoint and start command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["faraday-server"]