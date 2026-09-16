# dotfiles-server

This repository contains my reusable Ubuntu server configuration for deployment environments.

It is designed to provide a consistent baseline across:

- AWS EC2
- Azure Virtual Machines
- Self-hosted Ubuntu servers
- Home lab / portfolio servers
- Servers exposed through Cloudflare Tunnel

The goal is to make a new Ubuntu server reproducible with a single bootstrap script.

---

## Overview

This setup provides:

- A consistent Zsh environment
- Oh My Zsh configuration
- Centralized runtime management with `mise`
- Nginx for reverse proxying web applications
- Certbot for HTTPS certificate management
- A standard `/var/www/apps` application directory
- Reproducible server configuration across environments

---

## Project Structure

```sh
dotfiles-server/
├── .config/
│   └── mise/
│       └── config.toml
├── .gitignore
├── .zshrc
├── install.sh
└── README.md
```

---

## Managed by `mise`

The following runtimes and tools are installed and managed through `mise`.

### Languages

- Node.js
- Bun
- Python
- Java
- Go
- Rust
- .NET
- Ruby

### Tools

- AWS CLI
- uv
- just

Vite+ is installed separately from `mise`.

All managed runtimes and tools are configured in:

```text
.config/mise/config.toml
```

---

## Server Packages

The install script also installs common Ubuntu server packages and development dependencies, including:

- Git
- curl
- wget
- Zsh
- Nginx
- Certbot
- Certbot Nginx plugin
- OpenSSL
- SQLite
- build-essential
- common compiler and library dependencies

These packages provide a general-purpose environment capable of running applications written in multiple languages.

---

## Installation

Clone the repository:

```sh
git clone https://github.com/BradleyParkerDev/dotfiles-server.git
```

Enter the repository:

```sh
cd ~/dotfiles-server
```

Make the installer executable if necessary:

```sh
chmod +x install.sh
```

Run the bootstrap script:

```sh
./install.sh
```

When installation is complete:

```sh
exec zsh
```

---

## What the Install Script Does

`install.sh` bootstraps a new Ubuntu server by:

- Verifying that the machine uses an `apt`-based Linux distribution
- Updating installed system packages
- Installing server dependencies
- Installing Git, Zsh, Nginx, Certbot, and supporting packages
- Creating `/var/www/apps`
- Assigning the application directory to the current user
- Creating `~/.config/mise`
- Installing Oh My Zsh
- Symlinking the repository `.zshrc` to `~/.zshrc`
- Symlinking the repository mise configuration to `~/.config/mise/config.toml`
- Installing `mise`
- Trusting the mise configuration
- Installing all configured runtimes and tools
- Installing Vite+
- Enabling and starting Nginx
- Setting Zsh as the user's default shell

---

## Shell Configuration

Shell behavior is configured through:

```text
.zshrc
```

The repository version is symlinked to:

```text
~/.zshrc
```

This means changes made to `.zshrc` inside the repository immediately affect the server environment.

The shell configuration includes:

- User-level PATH configuration
- `mise` activation
- Oh My Zsh initialization
- Server-specific prompt/theme configuration
- Server directory shortcuts
- Vite+ environment loading

---

## Server Directory Shortcuts

The server environment uses a small number of environment variables for navigation.

### Dotfiles

```sh
$DOT
```

Points to:

```text
~/dotfiles-server
```

Example:

```sh
cd $DOT
```

### Applications

```sh
$APPS
```

Points to:

```text
/var/www/apps
```

Example:

```sh
cd $APPS
```

### Web Root

```sh
$WWW
```

Points to:

```text
/var/www
```

Example:

```sh
cd $WWW
```

---

## Application Directory

Applications deployed to the server are intended to live under:

```text
/var/www/apps
```

Example:

```text
/var/www/apps/
├── fastapi-app/
├── node-app/
├── springboot-app/
├── dotnet-app/
└── portfolio/
```

Individual application repositories remain responsible for their own dependencies and application-specific configuration.

`dotfiles-server` is responsible only for the shared server environment.

---

## Nginx

Nginx is installed and enabled automatically.

Verify the installation with:

```sh
nginx -v
```

Check the service:

```sh
sudo systemctl status nginx
```

Application-specific Nginx configuration can be added separately when applications are deployed.

---

## Certbot

Certbot and the Nginx Certbot plugin are installed automatically.

The installer does not request or configure certificates.

Certificate creation should be performed only after:

- DNS is configured
- The domain points to the server
- Nginx is configured for the application
- Ports 80 and 443 are reachable when required

Verify Certbot with:

```sh
certbot --version
```

---

## Managing Runtimes

Install all configured runtimes:

```sh
mise install
```

View installed runtimes:

```sh
mise list
```

Check the mise installation:

```sh
mise doctor
```

Upgrade configured runtimes:

```sh
mise upgrade
```

---

## Configuration Symlinks

The installer creates the following symlinks:

```text
~/.zshrc
    -> ~/dotfiles-server/.zshrc
```

and:

```text
~/.config/mise/config.toml
    -> ~/dotfiles-server/.config/mise/config.toml
```

This keeps the repository as the source of truth for server configuration.

---

## Deployment Philosophy

This repository provides a reusable baseline rather than application-specific infrastructure.

The server environment is responsible for:

- Linux system packages
- Zsh
- Oh My Zsh
- runtime management
- Nginx
- Certbot
- shared server directories

Individual applications are responsible for:

- application source code
- application dependencies
- environment variables
- database configuration
- systemd services
- Nginx site configuration
- deployment-specific settings

---

## Intended Environments

This configuration is intended primarily for Ubuntu servers running in environments such as:

```text
AWS EC2
Azure VM
Self-hosted Ubuntu
Home lab
Portfolio server
Cloudflare Tunnel origin server
```

The server provider should not materially change the base environment.

---

## Notes

- Ubuntu is the primary target operating system.
- `$HOME` is used where possible for portability between server users.
- `/var/www/apps` is used as the standard application directory.
- `mise` is the primary runtime and tool version manager.
- The repository is intended to make rebuilding a server straightforward.
- Application source code should remain in separate repositories.
- Secrets and credentials should never be committed to this repository.

---

## Author

Bradley Parker
