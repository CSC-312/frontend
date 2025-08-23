# ---- Node.js stage for Prisma ----
FROM node:20-alpine AS node_prisma

WORKDIR /app

COPY package*.json ./
RUN npm install

# ---- Python stage ----
FROM python:3.12-slim-bookworm

# Install uv (Python package manager)
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

WORKDIR /app

# Copy Python dependencies
COPY pyproject.toml uv.lock ./
RUN uv sync --locked

# Add a non-root user
RUN useradd -m -d /home/app -s /bin/bash app
USER app

# Copy app code (after switching to user for correct permissions)
COPY --chown=app:app . .

# Copy node_modules and Prisma client from Node stage
COPY --from=node_prisma /app/node_modules ./node_modules
COPY --from=node_prisma /app/package.json ./package.json
COPY --from=node_prisma /app/package-lock.json ./package-lock.json

# Generate Prisma client and run migrations
RUN npx prisma generate
RUN npx prisma migrate deploy

ENV PYTHONPATH=/app

EXPOSE 8000

CMD ["chainlit", "run", "frontend/main.py", "--host", "0.0.0.0"]