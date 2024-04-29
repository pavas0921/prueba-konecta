# Usar una imagen de Node.js como base
FROM node:latest

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Instalar PostgreSQL
RUN apt-get update && apt-get install -y postgresql postgresql-contrib

# Copiar los archivos de package.json y package-lock.json del backend y frontend
COPY backend/package*.json ./backend/
COPY frontend/package*.json ./frontend/

# Instalar dependencias del backend
WORKDIR /app/backend
RUN npm install
RUN npx prisma db push

# Volver al directorio principal de la aplicación
WORKDIR /app

# Instalar dependencias del frontend
WORKDIR /app/frontend
RUN npm install

# Volver al directorio principal de la aplicación
WORKDIR /app

# Copiar el código fuente del backend y frontend al contenedor
COPY . .

# Exponer el puerto 3000 para el servidor de desarrollo del frontend
EXPOSE 3000

# Exponer el puerto 8080 para el servidor de Node.js del backend
EXPOSE 8080

# Comando para iniciar PostgreSQL
CMD service postgresql start && \
    # Crear base de datos y usuario
    su - postgres -c "psql -c \"CREATE DATABASE db_konecta;\"" && \
    su - postgres -c "psql -c \"CREATE USER postgres WITH PASSWORD '12345*';\"" && \
    su - postgres -c "psql -c \"ALTER ROLE postgres SET client_encoding TO 'utf8';\"" && \
    su - postgres -c "psql -c \"ALTER ROLE postgres SET default_transaction_isolation TO 'read committed';\"" && \
    su - postgres -c "psql -c \"ALTER ROLE postgres SET timezone TO 'UTC';\"" && \
    # Iniciar backend y frontend
    npm run dev
