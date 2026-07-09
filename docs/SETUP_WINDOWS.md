# Windows Setup Guide

This guide explains how to install the tools needed to run PFMP Manager on Windows, either with Docker Compose or with local services. Commands are written for PowerShell unless noted. Some installers may require PowerShell as Administrator.

For actual run commands after installation, see the main [README](../README.md).

## Required Tools

| Tool | Why it is needed |
| --- | --- |
| Git | Clone the repository and manage changes. |
| Docker Desktop | Run MySQL, API, and Flutter Web containers. |
| Docker Compose plugin | Start all services with `docker compose up`. Bundled with Docker Desktop. |
| .NET SDK 9 | Build and run the ASP.NET Core API locally. |
| Flutter SDK | Run or build the Flutter frontend locally. |
| MySQL client or Workbench (optional) | Inspect, import, or export the database. |
| VS Code or Visual Studio (optional) | Development environment. |

## 1. Git

Download: [Git for Windows](https://git-scm.com/downloads/win)

```powershell
winget install --id Git.Git -e
```

Verify:

```powershell
git --version
```

## 2. Docker Desktop

Download: [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)

```powershell
winget install --id Docker.DockerDesktop -e
```

Open Docker Desktop, wait until it is running, then verify:

```powershell
docker --version
docker compose version
```

If Docker commands fail, restart Windows and open Docker Desktop again.

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

If `flutter` is not recognized, confirm `C:\src\flutter\bin` is on PATH or restart the computer.

## 5. MySQL Workbench (Optional)

Download: [MySQL Workbench](https://dev.mysql.com/downloads/workbench/)

```powershell
winget install --id Oracle.MySQLWorkbench -e
```

## Install Project Dependencies for Local Runs

```powershell
cd PFMPManager.Api
dotnet restore
dotnet build

cd ..\appli_pfmp
flutter pub get
```

If you run with Docker, `docker compose up --build` builds the services automatically.

## Verify the Toolchain

```powershell
git --version
docker --version
docker compose version
dotnet --version
flutter --version
flutter doctor
```

If every command succeeds, continue with the run instructions in the main [README](../README.md).
