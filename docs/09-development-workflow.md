# 09 - Development workflow

## Prerequisites

To run everything with Docker:

- Git;
- Docker Desktop or Docker Engine;
- Docker Compose;
- a local `.env` file.

To run outside Docker:

- .NET 9 SDK;
- Flutter SDK compatible with Dart `^3.11.5`;
- MySQL 8;
- a Chrome/Edge browser for Flutter Web.

Existing setup guides:

- [Windows setup](SETUP_WINDOWS.md)
- [macOS setup](SETUP_MACOS.md)
- [Linux setup](SETUP_LINUX.md)

## Clone the project

```bash
git clone <repository-url>
cd Projet-WebApp-PFMP
```

## Create `.env`

```powershell
Copy-Item .env.example .env
```

Then edit `.env` with local values.

Do not commit `.env`.

## First Docker run

Create the volume:

```bash
docker volume create docker-test_mysql_data
```

Start:

```bash
docker compose up --build
```

Check:

```bash
docker compose ps
```

Open:

```text
http://localhost:65427
```

## Rebuilding after a change

Full rebuild:

```bash
docker compose up --build
```

Production-style rebuild:

```bash
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d --build
```

Stop:

```bash
docker compose down
```

## Running the API outside Docker

```bash
cd PFMPManager.Api
dotnet restore
dotnet run --launch-profile http
```

URL:

```text
http://localhost:5002
```

OpenAPI JSON in development:

```text
http://localhost:5002/openapi/v1.json
```

## Running Flutter outside Docker

```bash
cd appli_pfmp
flutter pub get
flutter run -d chrome --web-port 65427
```

Note: the Flutter code uses `/api/...`. If Flutter is served by its own dev server, you need to check how `/api` is proxied to the API. In Docker, Nginx already handles this.

## Testing changes

Backend:

```bash
cd PFMPManager.Api
dotnet build
```

Frontend:

Use Flutter **3.47.9**, including Dart **3.13.7**, for the ECC version. This is
the SDK used to verify the committed lockfile. Its Linux x64 archive and SHA-256
are recorded in the [official Flutter release manifest](https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json)
and pinned in [ECC Flutter CI](../.github/workflows/ecc-flutter.yml).

Run the following from the ECC worktree:

```bash
cd appli_pfmp
flutter --version
flutter pub get --enforce-lockfile
dart format --output=none --set-exit-if-changed lib/data/http_client.dart lib/data/http_client_native.dart lib/data/http_client_web.dart test
flutter analyze --no-pub --no-fatal-infos
flutter test --no-pub --reporter expanded
flutter test --no-pub --reporter expanded --test-randomize-ordering-seed=417
flutter build web --no-pub
```

The complete native suite currently contains 28 tests; both test commands run
every test under `test/`, including future additions. These tests need no API
server, database, configured secrets, browser, or Chrome launcher workaround.
The web build checks compilation, including the SDK's default Wasm dry run.
Neither native tests nor a successful web build verify browser login, HttpOnly
cookies, credential exchange, CORS, or session refresh. Those require separate
browser acceptance testing against a running API and the intended proxy/origin.

Locked restoration fails if the committed versions or package content hashes
cannot be honored. CI restores from the network without a dependency cache;
developers with all packages cached can add `--offline` to the restore command.
Do not run a dependency upgrade as part of CI or regenerate the lockfile merely
to make a different SDK pass.

Flutter 3.47.9 automatically adds build/platform exclusions to
`analysis_options.yaml` during `flutter pub get`. In CI, the restore step copies
the file to the runner's temporary directory and restores those exact bytes on
exit, so analysis uses the committed lint configuration. Developers keeping the
same configuration can capture and restore this file's bytes around `pub get`
as well; preserve any local edits. No lint rule or diagnostic severity is changed
by this workflow.

Full-application analysis reports the existing informational diagnostics in its
console output and explains the policy in the GitHub job summary. The verified
Stage 1 baseline is 18 informational diagnostics, zero warnings, and zero errors.
`--no-fatal-infos` makes informational diagnostics nonfatal, including any new
ones; it does not hide them. Warnings and errors still fail CI. There is no
blanket `continue-on-error`. Formatting is enforced for the three HTTP factory
files and all tests; the legacy application files are outside this formatting
gate to avoid an unrelated reformat.

The workflow runs only on pushes to `review/ecc-native-tests`, on an Ubuntu
24.04 runner, using a checksum-verified official Flutter archive and a checkout
action pinned to a full commit SHA. It grants only `contents: read`, does not
persist checkout credentials, and performs no deployment or Git write. It has
no manual dispatch trigger. A local passing run does not establish successful
GitHub-hosted execution; that can be checked only after an authorized commit and
push of the ECC candidate.

Recommended manual tests:

- login;
- logout;
- student role access;
- administrator role access;
- `403` rejection on unauthorized endpoints;
- application creation/edit;
- PFMP creation;
- logbook;
- messaging;
- attendance;
- production-style with Nginx `/api`.

See [10 - Testing checklist](10-testing-checklist.md).

## Recommended Git workflow

The original and ECC versions are maintained independently and must never be
merged, rebased, cherry-picked, or overwritten into each other.

| Version | Branch | Workspace | Policy |
|---|---|---|---|
| Original | `main` at `f79aee2805bb049ad60a46c202dac797fbdfd24a` | `pfmp-original` | Preserve unchanged |
| ECC | `review/ecc-native-tests` | `pfmp-native-tests` | All future ECC development |

The older `pfmp` worktree remains on `review/ecc`, which already contains ECC
commits. Keep its tracked and untracked work intact; it is a historical
workspace, not the original version.

Before ECC development, verify the workspace and branch:

```bash
cd pfmp-native-tests
git worktree list
git branch --show-current
git status
```

The branch must be `review/ecc-native-tests`. Do not pull changes into `main`,
use a merge-to-main release flow, or switch the dirty historical worktree to
another branch. Review changes and obtain the required authorization before
staging, committing, pushing, creating worktrees, or changing GitHub settings.

## Contribution rules

- Never commit `.env`.
- Never commit secrets in `appsettings.json`, the documentation, or screenshots.
- Keep `.env.example` filled with dummy values.
- Document any API route changes.
- Add or update the testing checklist whenever a flow changes.
- Take a MySQL backup before any change that risks affecting the data.

## Backing up before sensitive changes

See [MySQL backup & restore](DATABASE_BACKUP.md).

Example:

```bash
docker exec pfmp_mysql mysqldump -uroot -pYOUR_PASSWORD pfmp_manager > backups/pfmp_manager_before_changes.sql
```

## If you get stuck

See [Troubleshooting](TROUBLESHOOTING.md) for common problems: CORS errors, rejected cookies, MySQL connection issues, a missing Docker volume, and more.

## Things to check regularly

- The Docker volume exists.
- Containers are healthy/up.
- The Nginx `/api` proxy works.
- Cookies are set after login.
- The API rejects unauthorized access.
- The documentation stays aligned with the controllers and services.
