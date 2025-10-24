# MeteoIpso – Parallele Messstationen, verteilte Knoten, zentrale Auswertung

**Kurzbeschreibung**  
MeteoIpso ist ein verteiltes .NET-8-System zur Erfassung & Auswertung meteorologischer Daten.  
Es besteht aus **Station** (Edge, Sensor-Simulation + Regeln), **LocalNode** (gRPC-Ingestion & Query-API) und **Central** (Blazor Server UI). Kommunikation über **gRPC** mit **Protobuf-Contracts**.

**Kernregeln (auf der Station, deterministisch):**
1) Bei **Regen** (Lidar) wird die **Feuchtemessung ausgesetzt**.  
2) Bei **Luftdruck > 950 hPa** wird die **Temperatur-Messfrequenz verdoppelt** (Intervall halbiert).

---

## Inhaltsverzeichnis
- [Features](#features)
- [Repository-Struktur](#repository-struktur)
- [Voraussetzungen](#voraussetzungen)
- [Quick Start (empfohlen)](#quick-start-empfohlen)
  - [A) CLI-Start (3 Terminals)](#a-cli-start-3-terminals)
  - [B) Visual Studio (Multi-Startup)](#b-visual-studio-multi-startup)
  - [C) Alternative: einmal alles bauen](#c-alternative-einmal-alles-bauen)
- [Konfiguration](#konfiguration)
- [Tests](#tests)
- [Container (optional)](#container-optional)
- [CI/CD](#cicd)
- [Architektur – Kurzüberblick](#architektur--kurzüberblick)
- [Observability](#observability)
- [Roadmap](#roadmap)
- [Lizenz](#lizenz)
- [Kontakt](#kontakt)

---

## Features
- **Station**: simulierte Sensoren (Lidar, Feuchte, Druck, Temperatur) + lokale Regel-Engine (inkl. Hysterese)
- **LocalNode**: gRPC-Ingestion, Validierung, Zwischenspeicher, Query-API; Idempotenz (Batch-IDs), Backoff/Retry
- **Central (Blazor Server)**: UI für Datenansicht/Analyse
- **Contracts**: Protobuf (Published Language), evolvierbar
- **Logs**: Serilog (strukturiert); Metriken/Traces vorbereitet
- **CI**: GitHub Actions vorhanden; CD-Pfad vorbereitet

---

## Repository-Struktur
.github/workflows/ # CI/CD-Workflows
central/ # Blazor Server UI
localnode/ # gRPC-Ingestion + Query-API
station/ # Sensor-Simulation + Regel-Engine (Edge)
shared/ # Gemeinsame Contracts/Protos/Utils
tests/ # Unit/Integration
Docs/ # Dokumentation
plantuml Docs/ # Diagrammquellen
MeteoIpso.sln # Solution

yaml
Copy code

---

## Voraussetzungen
- **.NET SDK 8.0+**
- Optional: **Docker**
- IDE nach Wahl (Visual Studio 2022 / Rider / VS Code)

---

## Quick Start (empfohlen)

> **Reihenfolge**: zuerst **LocalNode**, dann **Station**, danach **Central**.  
> So ist sichergestellt, dass Ingestion/Query erreichbar sind, wenn Station/Central starten.

### A) CLI-Start (3 Terminals)

**1) LocalNode starten**
```bash
dotnet restore
dotnet build
dotnet run --project ./localnode
2) Station starten (neues Terminal)

bash
dotnet run --project ./station
3) Central (Blazor Server) starten (neues Terminal)

bash
dotnet run --project ./central
Achte in jedem Terminal auf die ausgegebenen URLs/Ports (Konsolen-Output).
Wenn ein Port belegt ist, passe ihn an (siehe Konfiguration unten).

B) Visual Studio (Multi-Startup)
MeteoIpso.sln öffnen

Solution → Rechtsklick → Set Startup Projects…

Multiple startup projects wählen und die Reihenfolge setzen:

localnode → Start

station → Start

central → Start

F5.

C) Alternative: einmal alles bauen
bash
dotnet clean
dotnet restore
dotnet build --configuration Release
Danach wie unter A) starten.

Konfiguration
Standardmäßig lesen die Projekte ihre URLs/Ports aus launchSettings.json bzw. appsettings*.json.
Du kannst zur Laufzeit umkonfigurieren:

bash
# Beispiel: gRPC-URL für LocalNode setzen
# (Adresse bei Bedarf anpassen)
set ASPNETCORE_URLS=http://localhost:5201
dotnet run --project ./localnode

# Beispiel: Central auf bestimmtem Port starten
set ASPNETCORE_URLS=http://localhost:5202
dotnet run --project ./central
Hinweis: Wenn Central oder Station den LocalNode nicht erreichen, prüfe:

stimmt die gRPC-URL (Host/Port) in den jeweiligen Settings?

laufen alle drei Prozesse ohne Fehler?

Firewall/Portbelegung?

Tests
bash
dotnet test
Empfohlene zusätzliche Tests:

Regen-Hysterese (ein/aus), Intervallwechsel bei 950 hPa

Offline-Puffer & Backoff, Idempotenz (Batch-IDs)

Lasttests (viele Stationen/Frequenzen)

Container (optional)
bash
docker build -t meteoipso/localnode ./localnode
docker build -t meteoipso/station   ./station
docker build -t meteoipso/central   ./central
Optional: docker-compose.yml für gemeinsamen Start mit Healthchecks.

CI/CD
CI: GitHub Actions (Build, Tests, Artefakte)
CD (empfohlen): Environments staging → Healthcheck/Smoke → Promotion nach production; automatisiertes Rollback (vorheriger Tag/Slot-Swap).
Siehe .github/workflows/.

Architektur – Kurzüberblick
Station (Edge): Sensor-Simulation + Regeln lokal; sendet Batches via gRPC; Puffer + Exponential Backoff.

LocalNode (Gateway): gRPC-Ingestion, Validierung, Zwischenspeicher, Query-API; Idempotenz über Batch-IDs.

Central (Blazor): UI/Analyse, nutzt die Query-API.

Contracts: Protobuf (Published Language), Evolution über optionale Felder.

Observability
Logs: Serilog (strukturierte JSON-Logs, Korrelation/Trace-IDs)

Metriken/Traces (empfohlen): Prometheus/OpenTelemetry; SLOs (P95-Latenz, Error-Rate) + Alerts

Roadmap
Persistenter Zwischenspeicher am LocalNode (Time-Series-Store, Retention)

Contract-/Smoke-Tests in der Pipeline, Canary/Blue-Green

Docker Compose & Lasttests (≥1000 Stationen)

Lizenz
Apache-2.0
