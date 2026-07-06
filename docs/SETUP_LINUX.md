# Linux Setup Guide

Other platform? [Windows](SETUP_WINDOWS.md) · [macOS](SETUP_MACOS.md)

This guide walks through installing every tool needed to run PFMP Manager on
Linux, whether you use Docker Compose or run pieces locally. Commands target
Debian/Ubuntu (`apt`) — on Fedora, Arch, or another distro, swap in `dnf`,
`pacman`, etc.; package names are usually identical or very close.

For the actual run steps once tools are installed, see the main
[README](../README.md#run-with-docker) — this guide only covers getting the
toolchain in place.

## Required tools

| Tool | Why it's needed |
| --- | --- |
| Git | Clone the repository and push changes |
| Docker Engine + Compose plugin | Run MySQL, API, and optional Flutter Web containers |
| .NET SDK 9 | Build and run the ASP.NET Core API locally |
| Flutter SDK | Run or build the Flutter frontend locally |
| MySQL client (optional) | Inspect, import, or export the database |
| VS Code or JetBrains Rider (optional) | Development environment |

## 1. Git

```bash
sudo apt update
sudo apt install -y git
```

Verify:

```bash
git --version
```

## 2. Docker Engine + Compose plugin

Linux doesn't need "Docker Desktop" — the Docker Engine, CLI, and Compose
plugin are enough, and it's what production Linux servers run too.

Official convenience script (fine for a dev machine):

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER
```

Log out and back in (or run `newgrp docker`) so the group change takes
effect, then verify:

```bash
docker --version
docker compose version
```

If `docker compose version` fails, install the plugin explicitly:

```bash
sudo apt install -y docker-compose-plugin
```

## 3. .NET SDK 9

Via Microsoft's package feed:

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

If your distro isn't Ubuntu, follow the distro-specific steps at
[.NET on Linux](https://learn.microsoft.com/dotnet/core/install/linux)
instead — the package feed URL differs per distro/version.

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

## 5. MySQL client (optional)

```bash
sudo apt install -y mysql-client
```

Or MySQL Workbench for a GUI:

```bash
sudo apt install -y mysql-workbench
```

## Install project dependencies

```bash
cd PFMPManager.Api
dotnet restore
dotnet build

cd ../appli_pfmp
flutter pub get
```

If you're running with Docker instead, `docker compose up --build` downloads
and builds the MySQL, API, and (if present) Flutter Web images automatically
— you can skip the two steps above.

## Verify the full toolchain

```bash
git --version
docker --version
docker compose version
dotnet --version
flutter --version
flutter doctor
```

If every command succeeds, continue with
[Run With Docker](../README.md#run-with-docker) or
[Run Locally](../README.md#run-locally) in the main README.
