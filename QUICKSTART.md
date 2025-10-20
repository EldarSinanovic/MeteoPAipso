# ?? MeteoIpso - Quick Start Guide

## ?? Schnellstart mit Scripts

### Option 1: Komplettes System starten (EMPFOHLEN)

Startet automatisch: LocalNode + Central + 2 Stationen

```powershell
.\scripts\start-all.ps1
```

Mit mehr Stationen:
```powershell
.\scripts\start-all.ps1 -Stations 5
```

Zum Beenden:
```powershell
.\scripts\stop-all.ps1
```

---

### Option 2: Nur Stationen starten

Voraussetzung: LocalNode und Central laufen bereits

```powershell
# 2 Stationen
.\scripts\start-stations.ps1

# 3 Stationen  
.\scripts\start-stations.ps1 -Count 3
```

Zum Beenden:
```powershell
.\scripts\stop-stations.ps1
```

---

### Option 3: Manuell starten

#### Terminal 1 - LocalNode
```powershell
dotnet run --project localnode
```

#### Terminal 2 - Central
```powershell
dotnet run --project central
```

#### Terminal 3 - Station 1
```powershell
dotnet run --project station -- station-001
```

#### Terminal 4 - Station 2
```powershell
dotnet run --project station -- station-002
```

---

## ?? URLs

Nach dem Start erreichbar unter:

- **Übersicht**: http://localhost:5000
- **Aggregates**: http://localhost:5000/aggregates  
- **LocalNode**: http://localhost:5001

---

## ?? Was du sehen wirst

### Übersicht-Seite
```
?????????????????????????????????????
?  Aktive Stationen: 2              ?
?  Gesamt Stationen: 2              ?
?  Sensor Typen: 4                  ?
?????????????????????????????????????

Station ID    | Sensor     | Messwert
?????????????????????????????????????
station-001   | temp       | 18.5 °C
station-002   | humidity   | 65.2 %
```

### Aggregates-Seite
Zeigt Durchschnittswerte über alle Stationen und Sensoren.

---

## ?? Tests ausführen

```powershell
# Alle Tests
dotnet test

# Nur LocalNode Tests
dotnet test tests/LocalNode.Tests

# Nur Station Tests
dotnet test tests/Station.Tests
```

---

## ??? Architektur

```
???????????????????
?  Central (UI)   ?  ? Blazor Web UI
?  Port 5000      ?
???????????????????
         ? gRPC
         ?
???????????????????
?  LocalNode      ?  ? Aggregation Server
?  Port 5001      ?
???????????????????
         ? gRPC
    ????????????????????????
    ?         ?            ?
??????????? ??????????? ???????????
?Station 1? ?Station 2? ?Station 3?
??????????? ??????????? ???????????
```

---

## ?? Verfügbare Launch Profiles (Visual Studio)

Das Station-Projekt hat folgende Profile:

- **Station-001** - Erste Station
- **Station-002** - Zweite Station  
- **Station-003** - Dritte Station

In Visual Studio:
1. Wähle das `station` Projekt
2. Dropdown neben "Start" ? Wähle Profile
3. Klicke auf "Start"

---

## ?? Troubleshooting

### LocalNode nicht erreichbar
```powershell
# Prüfe ob Port 5001 belegt ist
netstat -ano | findstr :5001

# Falls belegt, töte den Prozess
taskkill /PID <PID> /F
```

### Stationen verbinden nicht
- Prüfe ob LocalNode läuft: http://localhost:5001
- Prüfe Firewall-Einstellungen
- Logs in den Station-Fenstern prüfen

### Browser öffnet nicht automatisch
Öffne manuell: http://localhost:5000

---

## ?? Projektstruktur

```
MeteoIpso/
??? central/           # Blazor UI
??? localnode/         # gRPC Aggregation Server
??? station/           # Wetterstation Simulator
??? shared/            # Protobuf Definitions
??? tests/
?   ??? LocalNode.Tests/
?   ??? Station.Tests/
??? scripts/           # PowerShell Helper Scripts
    ??? start-all.ps1
    ??? stop-all.ps1
    ??? start-stations.ps1
    ??? stop-stations.ps1
```

---

## ?? Features

- ? Echtzeit-Datensammlung von mehreren Stationen
- ? Automatische Sensor-Koordination (Regen ? keine Luftfeuchtigkeit)
- ? Dynamische Mess-Intervalle (hoher Druck ? schnellere Temperatur-Messungen)
- ? Aggregation über alle Stationen
- ? Moderne Blazor UI
- ? In-Memory Datenspeicherung
- ? gRPC Kommunikation

---

## ?? Lizenz

MIT License - siehe LICENSE Datei
