FROM php:8.2-cli AS base

WORKDIR /app

RUN apt update && apt install -y unzip git libzip-dev && docker-php-ext-install zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

COPY composer.json ./

RUN composer install --no-dev

# compando para ejecutar el dockerfile y crear la imagen
# docker buildx build -t calculadora:base --target base .

FROM base AS dev 

RUN pecl install xdebug && docker-php-ext-enable xdebug

COPY ./docker/php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# . . es copiarlo todo 
COPY . .

# php -S localhost:8000 -t public

CMD [ "php","-S","0.0.0.0:8000","-t","public" ]

# compando para ejecutar el dockerfile y crear la imagen
# docker buildx build -t calculadora:dev --target dev .

# comando para montar el contenedor
# docker container run -d -p 8000:8000 -v .:/app calculadora:dev

FROM base AS test

RUN composer require --dev phpunit/phpunit

COPY . .

#./vendor/bin/phpunit --testdox tests

CMD [ "./vendor/bin/phpunit","--testdox","tests" ]

# compando para ejecutar el dockerfile y crear la imagen
# docker buildx build -t calculadora:test --target test .

# comando para montar el contenedor
# docker container run calculadora:test

FROM base AS prod

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN rm -rf docker/ tests/

EXPOSE 80

CMD [ "php","-S","0.0.0.0:80","-t","public" ]

# compando para ejecutar el dockerfile y crear la imagen
# docker buildx build -t calculadora:prod --target prod .

# comando para montar el contenedor
# docker container run -d -p 80:80 calculadora:prod