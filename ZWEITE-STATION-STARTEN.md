# ?? Zweite Station starten - EINFACHE L�SUNG

## ? Schnellste Methode

F�hre einfach dieses Script aus:

```powershell
.\scripts\start-station-002.ps1
```

**Das war's!** Nach 10 Sekunden sollten beide Stationen im Browser sichtbar sein.

---

## ?? Problem pr�fen

Bevor du etwas startest, pr�fe zuerst:

```powershell
.\scripts\check-stations.ps1
```

**Das zeigt dir:**
- ? Wie viele Stationen laufen
- ? Welche Station-IDs aktiv sind
- ? Konkrete Handlungsempfehlungen

---

## ?? Schritt-f�r-Schritt

### 1. Pr�fen
```powershell
.\scripts\check-stations.ps1
```

Wenn nur **1 Station** l�uft ? weiter zu Schritt 2

### 2. Zweite Station starten
```powershell
.\scripts\start-station-002.ps1
```

Ein neues PowerShell-Fenster �ffnet sich mit Station-002.

### 3. Warten (10 Sekunden)
Das Script wartet automatisch.

### 4. Browser pr�fen
Der Browser �ffnet sich automatisch.

**Dr�cke: `Ctrl + F5`** (Hard Refresh)

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
� station-001 (4 Sensoren)
� station-002 (4 Sensoren)
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
# Neues PowerShell-Fenster �ffnen
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
3. Im Browser **Ctrl + F5** dr�cken

Fertig! ??

---

## ?? H�ufigste Fehler

### "ok=False" in den Logs
**Bedeutung:** Validation schl�gt fehl

**L�sung:** System neu starten
```powershell
.\scripts\stop-all.ps1
.\scripts\start-all.ps1 -Stations 2
```

### Nur station-001 in der Tabelle
**Bedeutung:** Station-002 l�uft nicht oder sendet keine Daten

**L�sung:** 
```powershell
.\scripts\check-stations.ps1
```
Befolge die Anweisungen.

### Browser zeigt alte Daten
**L�sung:** Hard Refresh
```
Ctrl + Shift + Delete
? Cache leeren
? OK
? Ctrl + F5
```

---

## ? Neue Features

- ? **Auto-Refresh alle 3 Sekunden** - Neue Daten werden automatisch geladen
- ? **Gruppierung nach Station** - �bersichtliche Darstellung
- ? **Sensor-Badges** - Farbige Markierung der Sensor-Typen
- ? **Sensor-Z�hler** - Zeigt wie viele Sensoren pro Station

---

**Probiere jetzt:**
```powershell
.\scripts\start-station-002.ps1
```
