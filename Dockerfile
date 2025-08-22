# Use an official Python image
FROM python:3.12-slim

# Set work directory
WORKDIR /app

# Copy requirements (if you have requirements.txt)
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Or, if you use pyproject.toml (PDM/Poetry), copy and install accordingly
# COPY pyproject.toml ./
# RUN pip install pdm && pdm install

# Copy the rest of your app
COPY . .

# Expose the port Chainlit uses
EXPOSE 8000

# Run Chainlit app
CMD ["chainlit", "run", "frontend/main.py", "--host", "0.0.0.0"]