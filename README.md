# Hypermodular DNS Solution with CoreDNS and docker-gen

A streamlined DNS solution for Docker environments that combines CoreDNS and docker-gen in a single container for simplified local development and testing.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration](#configuration)
- [Building the Image](#building-the-image)
- [Advantages](#advantages)
- [Troubleshooting](#troubleshooting)
- [License](#license)

## Features

- Single container solution combining CoreDNS and docker-gen
- Automatic DNS configuration for Docker containers
- Dynamic host file generation
- Lightweight and easy to integrate
- Supports multiple services and networks

## Prerequisites

- Docker 20.10.0 or higher
- Docker Compose 2.0.0 or higher
- Basic understanding of Docker networking

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/hypermodular/pytest.git
   cd pytest
   ```

2. Build the Docker image:
   ```bash
   docker-compose build
   ```

## Usage

1. Start the DNS service along with your application:
   ```bash
   docker-compose up -d
   ```

2. Configure your application containers to use this DNS service by adding to your `docker-compose.yml`:
   ```yaml
   services:
     your-service:
       dns: hyper-dns
       networks:
         - your_network
   ```

## Configuration

### CoreDNS Configuration
CoreDNS configuration is managed through the `Corefile` in the project root. By default, it's configured to:
- Listen on port 53
- Use the hosts plugin for local resolution
- Enable caching for better performance

### docker-gen Template
The `docker-gen` template is located at `templates/hosts.tmpl`. It automatically generates host entries for all running containers.

## Building the Image

To build the custom image:

```bash
docker build -t hypermodular-dns .
```

## Advantages

- **Simplified Architecture**: Single container for both DNS and host generation
- **Easier Management**: One less container to manage and monitor
- **Better Performance**: Reduced network overhead
- **Simplified Networking**: No need to manage links between multiple containers
- **Version Control**: All configurations can be versioned with your project

## Troubleshooting

1. **DNS resolution not working**
   - Ensure containers are on the same Docker network
   - Check logs: `docker-compose logs -f hyper-dns`

2. **Hosts not updating**
   - Verify docker-gen has proper permissions to access the Docker socket
   - Check template syntax in `templates/hosts.tmpl`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

> **Note**: For any issues or feature requests, please open an issue in the GitHub repository.
