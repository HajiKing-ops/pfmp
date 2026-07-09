# Linux Setup Guide

Other platforms: [Windows](SETUP_WINDOWS.md) | [macOS](SETUP_MACOS.md)

This guide explains how to install the tools needed to run PFMP Manager on Linux, either with Docker Compose or with local services. Commands target Debian/Ubuntu with `apt`. On Fedora, Arch, or another distribution, use the equivalent package manager.

For actual run commands after installation, see the main [README](../README.md).

## Required Tools

| Tool | Why it is needed |
| --- | --- |
| Git | Clone the repository and manage changes. |
| Docker Engine + Compose plugin | Run MySQL, API, and Flutter Web containers. |
| .NET SDK 9 | Build and run the ASP.NET Core API locally. |
| Flutter SDK | Run or build the Flutter frontend locally. |
| MySQL client (optional) | Inspect, import, or export the database. |
| VS Code or JetBrains Rider (optional) | Development environment. |

## 1. Git

```bash
sudo apt update
sudo apt install -y git
git --version
```

## 2. Docker Engine and Compose Plugin

Docker Engine and the Compose plugin are enough for this project.

Convenience script for a development machine:

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
```

Log out and back in, or run `newgrp docker`, then verify:

```bash
docker --version
docker compose version
```

If `docker compose version` fails:

```bash
sudo apt install -y docker-compose-plugin
```

## 3. .NET SDK 9

For Ubuntu, use Microsoft's package feed:

```bash
wget https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt update
sudo apt install -y dotnet-sdk-9.0
```

Verify:

```bash
dotnet --version
```

For another distribution, follow the official [.NET on Linux](https://learn.microsoft.com/dotnet/core/install/linux) instructions.

## 4. Flutter SDK

Guide: [Flutter Linux Web setup](https://docs.flutter.dev/get-started/install/linux/web)

```bash
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa
mkdir -p ~/development
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

Verify:

```bash
flutter --version
flutter doctor
```

## 5. MySQL Client (Optional)

```bash
sudo apt install -y mysql-client
```

For a GUI:

```bash
sudo apt install -y mysql-workbench
```

## Install Project Dependencies for Local Runs

```bash
cd PFMPManager.Api
dotnet restore
dotnet build

cd ../appli_pfmp
flutter pub get
```

If you run with Docker, `docker compose up --build` builds the services automatically.

## Verify the Toolchain

```bash
git --version
docker --version
docker compose version
dotnet --version
flutter --version
flutter doctor
```

If every command succeeds, continue with the run instructions in the main [README](../README.md).
