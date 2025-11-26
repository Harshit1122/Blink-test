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
RUN useradd --create-home --shell /bin/bash faraday

# Set build working directory
WORKDIR /src

# Copy application code
COPY . /src

# Install Python dependencies
RUN pip install -U pip --no-cache-dir && \
    pip install --no-cache-dir -e .

# Copy entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Switch to runtime working directory and non-root user
WORKDIR /home/faraday
RUN chown -R faraday:faraday /home/faraday
USER faraday

# Create required directories
RUN mkdir -p /home/faraday/.faraday/{config,logs,session,storage}

# Expose application port
EXPOSE 5985

# Set entrypoint and start command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["faraday-server"]