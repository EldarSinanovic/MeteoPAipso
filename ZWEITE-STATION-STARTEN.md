# ?? Zweite Station starten - EINFACHE LÖSUNG

## ? Schnellste Methode

Führe einfach dieses Script aus:

```powershell
.\scripts\start-station-002.ps1
```

**Das war's!** Nach 10 Sekunden sollten beide Stationen im Browser sichtbar sein.

---

## ?? Problem prüfen

Bevor du etwas startest, prüfe zuerst:

```powershell
.\scripts\check-stations.ps1
```

**Das zeigt dir:**
- ? Wie viele Stationen laufen
- ? Welche Station-IDs aktiv sind
- ? Konkrete Handlungsempfehlungen

---

## ?? Schritt-für-Schritt

### 1. Prüfen
```powershell
.\scripts\check-stations.ps1
```

Wenn nur **1 Station** läuft ? weiter zu Schritt 2

### 2. Zweite Station starten
```powershell
.\scripts\start-station-002.ps1
```

Ein neues PowerShell-Fenster öffnet sich mit Station-002.

### 3. Warten (10 Sekunden)
Das Script wartet automatisch.

### 4. Browser prüfen
Der Browser öffnet sich automatisch.

**Drücke: `Ctrl + F5`** (Hard Refresh)

---

## ? Was du sehen solltest

### Im Station-002 PowerShell-Fenster:
```
[station-002] sent lidar=1.2 ok=True
[station-002] sent temperature=20.1 ok=True
[station-002] sent humidity=58.3 ok=True
[station-002] sent pressure=1015.2 ok=True
```

### Im Browser (http://localhost:5000):
```
???????????????????????????????????
? Aktive Stationen: 2             ?
? Gesamt Sensoren: 8              ?
? Sensor Typen: 4                 ?
???????????????????????????????????

Tabelle zeigt:
• station-001 (4 Sensoren)
• station-002 (4 Sensoren)
```

---

## ? Wenn es nicht funktioniert

### Option 1: System komplett neu starten
```powershell
.\scripts\stop-all.ps1
.\scripts\start-all.ps1 -Stations 2
```

Warte 15 Sekunden, dann:
```
http://localhost:5000
Ctrl + F5
```

### Option 2: Manuell zweite Station starten
```powershell
# Neues PowerShell-Fenster öffnen
cd C:\Users\sinan\source\repos\MeteoPAipso
dotnet run --project station -- station-002
```

### Option 3: Diagnose
```powershell
.\scripts\diagnose.ps1
```

---

## ?? Wichtig

Die Frontend-Seite **aktualisiert sich automatisch alle 3 Sekunden**.

Du musst also nur:
1. Station-002 starten
2. 10-15 Sekunden warten
3. Im Browser **Ctrl + F5** drücken

Fertig! ??

---

## ?? Häufigste Fehler

### "ok=False" in den Logs
**Bedeutung:** Validation schlägt fehl

**Lösung:** System neu starten
```powershell
.\scripts\stop-all.ps1
.\scripts\start-all.ps1 -Stations 2
```

### Nur station-001 in der Tabelle
**Bedeutung:** Station-002 läuft nicht oder sendet keine Daten

**Lösung:** 
```powershell
.\scripts\check-stations.ps1
```
Befolge die Anweisungen.

### Browser zeigt alte Daten
**Lösung:** Hard Refresh
```
Ctrl + Shift + Delete
? Cache leeren
? OK
? Ctrl + F5
```

---

## ? Neue Features

- ? **Auto-Refresh alle 3 Sekunden** - Neue Daten werden automatisch geladen
- ? **Gruppierung nach Station** - Übersichtliche Darstellung
- ? **Sensor-Badges** - Farbige Markierung der Sensor-Typen
- ? **Sensor-Zähler** - Zeigt wie viele Sensoren pro Station

---

**Probiere jetzt:**
```powershell
.\scripts\start-station-002.ps1
```
