# macOS Setup Guide

Other platforms: [Windows](SETUP_WINDOWS.md) | [Linux](SETUP_LINUX.md)

This guide explains how to install the tools needed to run PFMP Manager on macOS, either with Docker Compose or with local services. Commands use `zsh`, the default macOS shell.

For actual run commands after installation, see the main [README](../README.md).

## Required Tools

| Tool | Why it is needed |
| --- | --- |
| Homebrew | Package manager used in this guide. |
| Git | Clone the repository and manage changes. |
| Docker Desktop | Run MySQL, API, and Flutter Web containers. |
| Docker Compose plugin | Bundled with Docker Desktop. |
| .NET SDK 9 | Build and run the ASP.NET Core API locally. |
| Flutter SDK | Run or build the Flutter frontend locally. |
| MySQL Workbench (optional) | Inspect, import, or export the database. |
| VS Code or JetBrains Rider (optional) | Development environment. |

## 0. Homebrew

Skip if `brew --version` already works.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the instructions printed by Homebrew, then verify:

```bash
brew --version
```

## 1. Git

```bash
brew install git
git --version
```

## 2. Docker Desktop

Download: [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)

Or install with Homebrew:

```bash
brew install --cask docker
```

Open Docker from Applications, wait until it is running, then verify:

```bash
docker --version
docker compose version
```

## 3. .NET SDK 9

Download: [.NET 9](https://dotnet.microsoft.com/download/dotnet/9.0)

Or install with Homebrew:

```bash
brew install --cask dotnet-sdk
```

Verify:

```bash
dotnet --version
```

## 4. Flutter SDK

Guide: [Flutter macOS Web setup](https://docs.flutter.dev/get-started/install/macos/web)

With Homebrew:

```bash
brew install --cask flutter
```

Or manually:

```bash
mkdir -p ~/development
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/development/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

Verify:

```bash
flutter --version
flutter doctor
```

`flutter doctor` may report Xcode or CocoaPods issues. Those are required for iOS builds, not for this Flutter Web project.

## 5. MySQL Workbench (Optional)

Download: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)

Or install with Homebrew:

```bash
brew install --cask mysqlworkbench
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
