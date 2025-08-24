FROM python:3.12-slim-bookworm

# Install Node.js and npm directly from NodeSource
RUN apt-get update && apt-get install -y curl ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install uv and set up Python environment
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
WORKDIR /app

# Copy dependency files
COPY package*.json ./
COPY pyproject.toml uv.lock ./
COPY prisma ./prisma/

# Install Node.js dependencies and generate Prisma client
RUN npm ci && npx prisma generate

# Sync Python dependencies (install them in virtual environment)
RUN uv sync --locked

# Create non-root user
RUN useradd -m -d /home/app -s /bin/bash app
USER app

# Copy application code
COPY --chown=app:app . .

ENV PYTHONPATH=/app

# SOLUTION 1: Use the virtual environment's binary directly
CMD npx prisma migrate deploy && /app/.venv/bin/chainlit run main.py