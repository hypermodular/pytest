# Docker DNS and Web Service Example

This project demonstrates a simple setup with a web service and automatic DNS resolution between containers using Docker's built-in networking. It allows you to use custom domain names locally within your Docker environment.

## ⚠️ Important Note About Local DNS

This setup provides DNS resolution **only within the Docker network**. To access these domains from your host machine or local network, you have two options:

1. **For host machine access only**:
   - Add entries to your `/etc/hosts` file (Linux/macOS) or `C:\Windows\System32\drivers\etc\hosts` (Windows)
   - Example:
     ```
     127.0.0.1 example.local
     ```

2. **For network-wide access**:
   - Set up a local DNS server (like dnsmasq) on your host machine
   - Configure your router to use this DNS server
   - This is more complex but allows all devices on your network to resolve the custom domains

## Features

- 🚀 Nginx web server accessible at `http://localhost:${WEB_PORT:-8081}` (customize in .env)
- 🔄 Automatic DNS resolution between containers
- 🌐 Custom domain aliases (e.g., `example.local`)
- 🧪 Test client container for debugging
- ✅ Automated tests for DNS resolution and service accessibility
- 🐳 No custom Docker images needed - uses official images directly
- ⚙️ Easy configuration via environment variables
- 🔄 Automatic container restarts on failure
- 🔒 Isolated network for services

## Prerequisites

- Docker
- Docker Compose

## Getting Started

1. Copy the example environment file and customize it if needed:
   ```bash
   cp .env.example .env
   # Edit .env to change port settings if needed
   ```

2. Start the services:
   ```bash
   make up
   # This will automatically create .env if it doesn't exist
   ```

3. Access the web service:
   ```bash
   make web
   # or open http://localhost:8081 in your browser (or your custom port from .env)
   ```

## Traefik Setup with Automatic HTTPS

This project includes Traefik as a reverse proxy with automatic HTTPS using Let's Encrypt. Here's how to set it up:

### Prerequisites

1. A domain name (e.g., `example.com`) that points to your server's public IP
2. Ports 80 and 443 must be open in your firewall
3. Docker and Docker Compose installed

### Quick Start

1. Copy the example environment file and update it with your details:
   ```bash
   cp .env.example .env
   nano .env  # Edit the file with your details
   ```

2. Update these variables in `.env`:
   ```env
   TRAEFIK_DOMAIN=yourdomain.com
   TRAEFIK_EMAIL=your.email@example.com
   ENABLE_HTTPS=true
   ```

3. Start Traefik and your services:
   ```bash
   make traefik-up
   ```

4. Access your services:
   - Web service: `https://yourdomain.com`
   - Traefik dashboard: `https://traefik.yourdomain.com`

### How It Works

- Traefik automatically obtains SSL certificates from Let's Encrypt
- All HTTP traffic is automatically redirected to HTTPS
- The dashboard provides visibility into your services and routing

### Managing Traefik

- Start Traefik: `make traefik-up`
- Stop Traefik: `make traefik-down`
- View logs: `make traefik-logs`
- Open dashboard: `make traefik-dashboard`

### Adding New Services

To add a new service with HTTPS support, add these labels to your service in `docker-compose.traefik.yml`:

```yaml
services:
  myservice:
    # ... other config ...
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myservice.rule=Host(`service.${TRAEFIK_DOMAIN}`)"
      - "traefik.http.routers.myservice.entrypoints=websecure"
      - "traefik.http.routers.myservice.tls.certresolver=leresolver"
      - "traefik.http.services.myservice.loadbalancer.server.port=8080"
```

## Configuration

### Environment Variables

Customize the following settings in the `.env` file:

| Variable | Description | Default |
|----------|-------------|---------|
| `WEB_PORT` | Host port mapped to the web container | `8081` |
| `CONTAINER_PORT` | Internal port exposed by the web container | `80` |

Example `.env` file:
```env
# Web service port mapping
WEB_PORT=8081

# Internal container port (should match the service's exposed port)
CONTAINER_PORT=80
```

### DNS Configuration

The setup uses Docker's built-in DNS server for container name resolution. To add custom domains:

1. Edit `docker-compose.yml` and add aliases under the service's network configuration:
   ```yaml
   services:
     web:
       # ... other config ...
       networks:
         app_net:
           aliases:
             - example.local
             - myservice.local
   ```

2. Restart the services:
   ```bash
   make down
   make up
   ```

### Accessing Services from Host

To access services using custom domains from your host machine:

1. **Temporary solution** (edits required after each IP change):
   ```bash
   # Linux/macOS
   echo "127.0.0.1 example.local" | sudo tee -a /etc/hosts
   
   # Windows (Run as Administrator)
   # Add to C:\Windows\System32\drivers\etc\hosts:
   # 127.0.0.1 example.local
   ```

2. **Permanent solution** (recommended for development):
   - Use a local DNS server like dnsmasq
   - Or use a tool like `traefik` or `nginx-proxy` for automatic DNS resolution

## Project Structure

```
.
├── docker-compose.yml    # Docker Compose configuration
├── Makefile             # Common tasks
├── README.md            # This file
├── scripts/             # Utility scripts
└── tests/               # Test scripts
    └── test_dns.sh      # DNS and service tests
```

## Available Commands

- `make up` - Start all services
- `make down` - Stop and remove all containers
- `make test` - Run DNS and service tests
- `make shell` - Open a shell in the test client container
- `make logs` - View container logs
- `make status` - Show container status
- `make clean` - Clean up Docker resources

## Testing

Run the test suite to verify DNS resolution and service accessibility:

```bash
make test
```

## Accessing Services

### From Your Host Machine
- Web service: http://localhost:${WEB_PORT:-8081} (customize in .env)
- With custom domain (requires hosts file entry):
  - `http://example.local:${WEB_PORT:-8081}`

### From Within the Docker Network
- Using container name: `http://example-web`
- Using custom domain: `http://example.local`

### Testing DNS Resolution

Use the test client to verify DNS resolution:
```bash
# Get a shell in the test container
make shell

# Test DNS resolution
ping example-web
ping example.local

# Test HTTP access
curl http://example-web
curl http://example.local
```

## Troubleshooting

If you encounter port conflicts, you can check which process is using a port:

```bash
lsof -i :8081  # Check what's using port 8081
```

To clean up all Docker resources:

```bash
make clean
```

## License

MIT

---

## Use Cases

* 🧪 **Test Process Automation**
  Manage containerized test environments and services dynamically

* 🌍 **R\&D Infrastructure**
  Ideal for labs that require disposable DNS setups and reproducible resolution states

* 🧰 **Local Development Environments**
  Avoid hardcoded IPs and static host files; plug-and-play DNS setup for teams

* 🧵 **CI/CD Pipelines**
  Improve DNS discovery across stages with dynamic updates as containers change

---

## Architecture

```text
+---------------------+         +---------------------+
|  docker-gen         |  --->   |  hosts file (template) |
+---------------------+         +---------------------+
         |                               |
         V                               V
+---------------------------------------------+
|          CoreDNS                            |
|  uses hosts plugin to serve DNS             |
+---------------------------------------------+
         |
         V
  DNS Responses to other Docker services
```

---

## Modules

| Module       | Description                                 | Required |
| ------------ | ------------------------------------------- | -------- |
| `CoreDNS`    | DNS resolver that reads generated host data | ✅        |
| `docker-gen` | Monitors Docker API and updates DNS entries | ✅        |
| `hosts.tmpl` | Template for generating DNS config          | ✅        |
| `Corefile`   | CoreDNS config, customizable per use-case   | ✅        |

---

## Prerequisites

* Docker 20.10.0 or higher
* Docker Compose 2.0.0 or higher
* Access to Docker socket (`/var/run/docker.sock`)
* Optional: Familiarity with DNS or Docker networking

---

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/hypermodular/pytest.git
   cd pytest
   ```

2. Build the container:

   ```bash
   docker-compose build
   ```

---

## Usage

1. Launch the service:

   ```bash
   docker-compose up -d
   ```

2. Link your application container:

   ```yaml
   services:
     app:
       image: your-app
       dns:
         - hyper-dns
       networks:
         - your_network
   ```

---

## Configuration

### 🔧 CoreDNS (`Corefile`)

Example:

```
.:53 {
    hosts /etc/hosts.generated {
        fallthrough
    }
    cache 30
    log
    errors
}
```

* Listens on port 53
* Uses `hosts.generated` file created by docker-gen
* Can be extended with additional plugins (forwarding, etc.)

### 📄 docker-gen Template (`templates/hosts.tmpl`)

Example snippet:

```tmpl
{{ range $container := . }}
{{ $name := index $container.Names 0 }}
{{ $ip := $container.IP }}
{{ $name }} {{ $ip }}
{{ end }}
```

This dynamically creates a host mapping file reflecting the current Docker network state.

---

## Integration

* Supports integration with:

  * `docker-compose`
  * Standalone Docker hosts
  * Kubernetes (as auxiliary DNS)
* Compatible with `ERP`, `CI`, `test benches`, `DevOps platforms`
* Ideal for coupling with `MATLAB`, `Selenium Grids`, `Robot Framework`, etc.

---

## Building the Image

```bash
docker build -t hypermodular-dns .
```

---

## Advantages

* ✅ **Zero External Dependencies**
* ⚡ **Fast Startup and Sync**
* 🔁 **Auto-Sync with Docker Events**
* 🔐 **Secure by Design (read-only config, socket-limited access)**
* 🌍 **Cross-platform Compatible**

---

## Troubleshooting

* 🧭 **DNS resolution not working**

  * Check if `dns:` setting is applied in service
  * Validate Docker network visibility

* 🛠 **Hosts file not updating**

  * Ensure `docker-gen` has access to Docker socket
  * Check for syntax errors in the `hosts.tmpl` file

* 🧪 **Debug logs**

  ```bash
  docker-compose logs -f hyper-dns
  ```

---

## Roadmap

* [ ] Plugin support for other DNS resolvers
* [ ] UI dashboard for DNS overview
* [ ] Support for Kubernetes via sidecar model
* [ ] IPv6 & multi-host support
* [ ] Healthcheck & Prometheus metrics endpoint

---

## License

Licensed under the [MIT License](LICENSE).

---

> Need help or want to contribute?
> 👉 Open an issue or fork the repository at: [https://github.com/hypermodular/pytest](https://github.com/hypermodular/pytest)


