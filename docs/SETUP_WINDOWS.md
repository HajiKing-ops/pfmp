# Windows Setup Guide

Other platform? [macOS](SETUP_MACOS.md) · [Linux](SETUP_LINUX.md)

This guide walks through installing every tool needed to run PFMP Manager on
Windows, whether you use Docker Compose or run pieces locally. Commands are
PowerShell unless noted; some installs need PowerShell run **as
Administrator**.

For the actual run steps once tools are installed, see the main
[README](../README.md#run-with-docker) — this guide only covers getting the
toolchain in place.

## Required tools

| Tool | Why it's needed |
| --- | --- |
| Git | Clone the repository and push changes |
| Docker Desktop | Run MySQL, API, and optional Flutter Web containers |
| Docker Compose plugin | Start all services with `docker compose up` (bundled with Docker Desktop) |
| .NET SDK 9 | Build and run the ASP.NET Core API locally |
| Flutter SDK | Run or build the Flutter frontend locally |
| MySQL client (optional) | Inspect, import, or export the database |
| VS Code or Visual Studio (optional) | Development environment |

Each tool can be installed by downloading the official installer and clicking
through, or with `winget` from PowerShell. Both options are given below.

## 1. Git

Download: [Git for Windows](https://git-scm.com/downloads/win)

```powershell
winget install --id Git.Git -e
```

Close and reopen the terminal, then verify:

```powershell
git --version
```

## 2. Docker Desktop

Download: [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)

```powershell
winget install --id Docker.DockerDesktop -e
```

After installing: open Docker Desktop from the Start menu, wait until it
reports it's running, restart your terminal, then verify:

```powershell
docker --version
docker compose version
```

If Docker commands don't work, restart Windows once and reopen Docker Desktop.

## 3. .NET SDK 9

Download: [.NET 9](https://dotnet.microsoft.com/download/dotnet/9.0)

```powershell
winget install --id Microsoft.DotNet.SDK.9 -e
```

Verify:

```powershell
dotnet --version
```

## 4. Flutter SDK

Guide: [Flutter Windows Web setup](https://docs.flutter.dev/get-started/install/windows/web)

```powershell
mkdir C:\src
cd C:\src
git clone https://github.com/flutter/flutter.git -b stable
setx PATH "$env:PATH;C:\src\flutter\bin"
```

Close and reopen PowerShell, then verify:

```powershell
flutter --version
flutter doctor
```

If `flutter` isn't recognized, confirm `C:\src\flutter\bin` is on PATH, or
restart the computer.

## 5. MySQL Workbench (optional)

Only needed if you'd rather inspect the database with a GUI instead of
Docker/CLI commands.

Download: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)

```powershell
winget install --id Oracle.MySQLWorkbench -e
```

## Install project dependencies

```powershell
cd PFMPManager.Api
dotnet restore
dotnet build

cd ..\appli_pfmp
flutter pub get
```

If you're running with Docker instead, `docker compose up --build` downloads
and builds the MySQL, API, and (if present) Flutter Web images automatically —
you can skip the two steps above.

## Verify the full toolchain

```powershell
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
