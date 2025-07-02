# Hypermodular DNS Solution with CoreDNS and docker-gen

A modular and scalable DNS management solution tailored for Docker-based test and dev environments. Combine power, automation, and simplicity — all in a single containerized service.

> **Boost your development, test automation, and environment integration with a low-maintenance DNS layer.**

---

## Table of Contents

* [Overview](#overview)
* [Features](#features)
* [Use Cases](#use-cases)
* [Architecture](#architecture)
* [Modules](#modules)
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Usage](#usage)
* [Configuration](#configuration)
* [Integration](#integration)
* [Building the Image](#building-the-image)
* [Advantages](#advantages)
* [Troubleshooting](#troubleshooting)
* [Roadmap](#roadmap)
* [License](#license)

---

## Overview

**Hypermodular DNS** is a low-code/no-code DNS automation solution for containerized environments.

It combines:

* **CoreDNS** for DNS resolution
* **docker-gen** for automatic hostfile generation

All packed into **one lightweight container**, streamlining your development and test environments without sacrificing flexibility or control.

---

## Features

* 🔧 **Single Container**: CoreDNS + docker-gen in one image
* 📦 **Dynamic DNS**: Automatic resolution of running Docker containers
* 💡 **Low-Code Configuration**: Easy templating and setup
* 🌐 **Multi-Network Support**: Handles containers across isolated networks
* 🔒 **Secure & Lightweight**: No unnecessary overhead
* 📈 **Scalable & Modular**: Adaptable to various CI/CD or local environments

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


