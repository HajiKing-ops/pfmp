# Build stage: compile Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY . .
RUN flutter build web --release

# Runtime stage: serve Flutter Web with Nginx
FROM nginx:alpine AS final

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80