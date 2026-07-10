# macOS Setup Guide

Other platform? [Windows](SETUP_WINDOWS.md) · [Linux](SETUP_LINUX.md)

This guide walks through installing every tool needed to run PFMP Manager on
macOS, whether you use Docker Compose or run pieces locally. Commands are for
`zsh` (the macOS default) via Terminal.

For the actual run steps once tools are installed, see the main
[README](../README.md#run-with-docker) — this guide only covers getting the
toolchain in place.

## Required tools

| Tool | Why it's needed |
| --- | --- |
| Homebrew | Package manager used to install everything below |
| Git | Clone the repository and push changes |
| Docker Desktop | Run MySQL, API, and optional Flutter Web containers |
| Docker Compose plugin | Bundled with Docker Desktop |
| .NET SDK 9 | Build and run the ASP.NET Core API locally |
| Flutter SDK | Run or build the Flutter frontend locally |
| MySQL Workbench (optional) | Inspect, import, or export the database |
| VS Code or JetBrains Rider (optional) | Development environment |

## 0. Homebrew

Skip this if `brew --version` already works.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the "Next steps" it prints to add Homebrew to your PATH, then verify:

```bash
brew --version
```

## 1. Git

macOS ships with an old Git via Xcode Command Line Tools. To get a current
version:

```bash
brew install git
```

Verify:

```bash
git --version
```

## 2. Docker Desktop

Download: [Docker Desktop for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)

Or via Homebrew:

```bash
brew install --cask docker
```

Open Docker from Applications (or Spotlight), wait until it reports it's
running, then verify:

```bash
docker --version
docker compose version
```

If you download directly instead of using `brew`, pick the build that
matches your chip — Apple Silicon or Intel. Homebrew handles this
automatically.

## 3. .NET SDK 9

Download: [.NET 9](https://dotnet.microsoft.com/download/dotnet/9.0)

Or via Homebrew:

```bash
brew install --cask dotnet-sdk
```

Verify:

```bash
dotnet --version
```

## 4. Flutter SDK

Guide: [Flutter macOS Web setup](https://docs.flutter.dev/get-started/install/macos/web)

Via Homebrew:

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

`flutter doctor` may flag Xcode or CocoaPods — those are only needed for iOS
builds, not for Flutter Web, so they're safe to ignore for this project.

## 5. MySQL Workbench (optional)

Only needed if you'd rather inspect the database with a GUI instead of
Docker/CLI commands.

Download: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)

Or via Homebrew:

```bash
brew install --cask mysqlworkbench
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

Running into a problem instead? Check [Troubleshooting](TROUBLESHOOTING.md).
