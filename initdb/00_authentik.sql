CREATE DATABASE authentik;
CREATE USER authentik WITH ENCRYPTED PASSWORD 'authentik_password';
GRANT ALL PRIVILEGES ON DATABASE authentik TO authentik;
ALTER DATABASE authentik OWNER TO authentik;
