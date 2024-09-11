# Keycloak with Nginx and PostgreSQL

This project sets up a Keycloak server with Nginx as a reverse proxy and PostgreSQL as the database. The setup uses Docker Compose to manage the services.

## Prerequisites

- Docker
- Docker Compose

## Services

- **Postgres**: Database service for Keycloak.
- **Keycloak**: Identity and access management service.
- **Nginx**: Reverse proxy for Keycloak.

## Configuration

### Certificates

The `generate-wildcard-cert.ps1` script generates the necessary SSL certificates for Nginx. The configuration for the certificate is located in `config/cert/cert.cnf`.

### Nginx Configuration

The Nginx configuration is located in `data/nginx/nginx.conf`. It sets up two server blocks for `admin.local-keycloak.mx` and `auth.local-keycloak.mx`.

### Docker Compose

The `docker-compose.yml` file defines the services and their configurations.

## Usage

1. **Generate SSL Certificates**:
    ```sh
    pwsh Setup.ps1 -Operation generate
    ```

2. **Generate SSL Certificates (run as admin)**:
    ```sh
    pwsh Setup.ps1 -Operation generate
    ```

3. **Start Services**:
    ```sh
    docker-compose up -d
    ```

4. **Access Keycloak**:
    - Admin Console: `https://admin.local-keycloak.mx`
    - Authentication: `https://auth.local-keycloak.mx`

## Volumes

- **postgres\_data**: Stores PostgreSQL data.
- **keycloak\_data**: Stores Keycloak data.
- **nginx\_data**: Stores Nginx configuration and certificates.

## Networks

- **keycloak-network**: Bridge network for inter-service communication.

## Environment Variables

- **Postgres**:
    - `POSTGRES_DB`: Database name.
    - `POSTGRES_USER`: Database user.
    - `POSTGRES_PASSWORD`: Database password.

- **Keycloak**:
    - `DB_VENDOR`: Database vendor (postgres).
    - `DB_ADDR`: Database address.
    - `DB_PORT`: Database port.
    - `DB_DATABASE`: Database name.
    - `DB_USER`: Database user.
    - `DB_PASSWORD`: Database password.
    - `KEYCLOAK_ADMIN`: Admin username.
    - `KEYCLOAK_ADMIN_PASSWORD`: Admin password.
    - `KC_HOSTNAME`: Hostname for Keycloak.
    - `KC_HOSTNAME_ADMIN`: Hostname for Keycloak admin.
    - `KC_HTTP_ENABLED`: Enable HTTP (true).

## License

This project is licensed under the MIT License.