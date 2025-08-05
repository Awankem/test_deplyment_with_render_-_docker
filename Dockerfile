FROM php:8.2-fpm-alpine

# Install dependencies
RUN apk add --no-cache \
    freetype-dev \
    libjpeg-turbo-dev \
    libpng-dev \
    libzip-dev \
    oniguruma-dev \
    sqlite-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql mbstring exif pcntl bcmath gd

# Copy composer (only during build)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create user and group
RUN addgroup -g 1000 ipa_user && \
    adduser -u 1000 -D -G ipa_user -s /bin/bash ipa_user

# Set working directory
WORKDIR /var/www

# Create the database directory
RUN mkdir -p /var/www/database

# Set permissions for the database directory
RUN chown -R ipa_user:ipa_user /var/www/database
RUN chmod -R 775 /var/www/database  # Set the permissions

# Copy composer files first (better caching)
COPY composer.json composer.lock ./

# Copy application code
COPY --chown=ipa_user:ipa_user . .

# Ensure correct permissions for the working directory
RUN chown -R ipa_user:ipa_user /var/www

# Change user
USER ipa_user

# Create vendor directory manually
RUN mkdir -p vendor

# Install Composer dependencies
RUN composer install --no-dev --optimize-autoloader

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]