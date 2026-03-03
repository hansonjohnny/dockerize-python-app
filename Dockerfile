# ============================================
# Dockerize Python App Challenge
# ============================================
#
# YOUR TASK: Create a production-ready Dockerfile
#
# Requirements:
# 1. Use multi-stage build (builder + final stages)
# 2. Final image must be under 200MB
# 3. Run as non-root user (security)
# 4. Include a health check
# 5. Use python:3.11-slim for the final image
#
# Hints:
# - Stage 1 (builder): Install dependencies
# - Stage 2 (final): Copy only what's needed
# - Use --prefix=/install with pip to control where packages go
# - Create a user with: RUN useradd --create-home appuser
# - Health check can use Python urllib (curl not in slim image)
#
# ============================================

# TODO: Implement your Dockerfile here!
#
# Delete everything below and write your own.
# See README.md for step-by-step hints.

# This is a BROKEN starter - it works but has problems:
# - Image is too big (~1GB)
# - Runs as root (insecure)
# - No health check
# - No multi-stage build

#===================================================
#Stage 1: Builder
#===================================================
#start from Python base image
FROM python:3.11-slim  AS builder

#set working directory
WORKDIR /app

#install dependencies specific location
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install --no-compile -r requirements.txt 

#=========================================================
#stage 2: Final
#=========================================================
FROM python:3.11-slim

#Create non-root user for security
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

#Copy installed packages from builder
COPY --from=builder /install /usr/local

#Copy application code
COPY --chown=appuser:appuser src/ ./src/

#Set environment variables
ENV FLASK_APP=src/app.py
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5000
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

#Switch to non-root user
USER appuser

#Document the port
EXPOSE 5000

#Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

#Run the application
CMD ["python", "src/app.py"]


