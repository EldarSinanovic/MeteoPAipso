# ? Test-Checkliste: Mehrere Stationen

## ?? Was zu erwarten ist

Nach dem Start von 2 Stationen solltest du folgendes sehen:

### Im Browser (http://localhost:5000)

#### 1. Statistics Cards (oben)
```
??????????????????  ??????????????????  ??????????????????
? Aktive         ?  ? Gesamt         ?  ? Sensor         ?
? Stationen      ?  ? Sensoren       ?  ? Typen          ?
?                ?  ?                ?  ?                ?
?      2         ?  ?      8         ?  ?      4         ?
??????????????????  ??????????????????  ??????????????????
```

#### 2. Stationen-Tabelle

```
????????????????????????????????????????????????????????????????
? Station ID  ? Sensor Typ   ? Messwert  ? Zeitstempel? Status ?
????????????????????????????????????????????????????????????????
? station-001 ? humidity     ?  65.2 %   ? 22:15:30   ? ACTIVE ?
? (4 Sensoren)? lidar        ?  0.0 mm   ? 22:15:31   ? ACTIVE ?
?             ? pressure     ? 1013 hPa  ? 22:15:32   ? ACTIVE ?
?             ? temperature  ?  18.5 °C  ? 22:15:33   ? ACTIVE ?
????????????????????????????????????????????????????????????????
? station-002 ? humidity     ?  58.3 %   ? 22:15:34   ? ACTIVE ?
? (4 Sensoren)? lidar        ?  1.2 mm   ? 22:15:35   ? ACTIVE ?
?             ? pressure     ? 1015 hPa  ? 22:15:36   ? ACTIVE ?
?             ? temperature  ?  20.1 °C  ? 22:15:37   ? ACTIVE ?
????????????????????????????????????????????????????????????????
```

---

## ?? Test-Schritte

### Schritt 1: System starten

```powershell
# Im Projekt-Root-Verzeichnis
cd C:\Users\sinan\source\repos\MeteoPAipso

# System mit 2 Stationen starten
.\scripts\start-all.ps1 -Stations 2
```

**Erwartetes Ergebnis:**
- ? 4 PowerShell-Fenster öffnen
- ? Browser öffnet automatisch http://localhost:5000
- ? Ausgabe zeigt erfolgreichen Start

### Schritt 2: LocalNode prüfen (10 Sekunden warten)

**In einem neuen Terminal:**
```powershell
curl http://localhost:5001
```

**Erwartetes Ergebnis:**
```
LocalNode up
```

### Schritt 3: Station-Logs prüfen

**Schau in die PowerShell-Fenster der Stationen:**

**Station-001 sollte zeigen:**
```
[station-001] sent temperature=18.5 ok=True
[station-001] sent humidity=65.2 ok=True
[station-001] sent lidar=0.0 ok=True
[station-001] sent pressure=1013.4 ok=True
```

**Station-002 sollte zeigen:**
```
[station-002] sent temperature=20.1 ok=True
[station-002] sent humidity=58.3 ok=True
[station-002] sent lidar=1.2 ok=True
[station-002] sent pressure=1015.2 ok=True
```

### Schritt 4: Frontend prüfen

**Öffne:** http://localhost:5000

**Prüfe:**
- ?? "Aktive Stationen" zeigt **2**
- ?? "Gesamt Sensoren" zeigt **8**
- ?? Tabelle zeigt **station-001** mit 4 Sensoren
- ?? Tabelle zeigt **station-002** mit 4 Sensoren
- ?? Alle Sensoren haben aktuelle Zeitstempel (< 10 Sekunden alt)
- ?? Werte ändern sich beim Refresh (F5)

### Schritt 5: Aggregates-Seite prüfen

**Öffne:** http://localhost:5000/aggregates

**Prüfe:**
- ?? Zeigt Durchschnittswerte über alle Stationen
- ?? Zeigt Anzahl der Messungen pro Sensor-Typ
- ?? "Total Measurements" > 0

---

## ?? Debug-Befehle

### Zeige alle laufenden Prozesse

```powershell
Get-Process | Where-Object { 
    $_.ProcessName -eq 'dotnet' 
} | Select-Object Id, ProcessName, StartTime | Format-Table
```

**Erwartetes Ergebnis: 4 dotnet Prozesse**

### Zeige Netzwerk-Verbindungen

```powershell
netstat -ano | findstr :5001
```

**Erwartetes Ergebnis:**
```
TCP    0.0.0.0:5001    0.0.0.0:0    LISTENING    <PID>
```

### Prüfe ob Stationen verbunden sind

**In LocalNode PowerShell-Fenster solltest du sehen:**
```
[Ingress] station-001 temperature=18.5 state=Active
[Ingress] station-002 humidity=65.2 state=Active
```

---

## ? Häufige Probleme

### Problem 1: Nur 1 Station sichtbar

**Ursache:** Alte Browser-Cache

**Lösung:**
```
Ctrl + Shift + R (Hard Refresh)
Oder Ctrl + F5
```

### Problem 2: "Keine Stationen gefunden"

**Ursache:** LocalNode nicht erreichbar oder Stationen senden keine Daten

**Lösung:**
```powershell
# System neu starten
.\scripts\stop-all.ps1
Start-Sleep 2
.\scripts\start-all.ps1 -Stations 2
```

### Problem 3: Stationen zeigen "ok=False"

**Ursache:** Validation schlägt fehl

**Prüfe Station-Logs:**
```
[Ingress] station-001 temperature=18.5 rejected: <GRUND>
```

**Häufige Gründe:**
- Zeitstempel in der Zukunft
- Werte außerhalb gültiger Bereiche
- Fehlende StationId

### Problem 4: Port 5001 bereits belegt

**Lösung:**
```powershell
# Finde Prozess
netstat -ano | findstr :5001

# Töte Prozess (ersetze <PID>)
taskkill /PID <PID> /F
```

---

## ?? Performance-Test

### Starte mit 5 Stationen

```powershell
.\scripts\start-all.ps1 -Stations 5
```

**Erwartung:**
- ? Aktive Stationen: **5**
- ? Gesamt Sensoren: **20** (4 pro Station)
- ? System läuft flüssig
- ? Alle Stationen senden Daten

---

## ? Erfolgs-Kriterien

Das System funktioniert korrekt, wenn:

1. ? Alle gestarteten Stationen im Frontend sichtbar sind
2. ? Jede Station zeigt 4 Sensoren (temperature, humidity, pressure, lidar)
3. ? Zeitstempel aktualisieren sich kontinuierlich
4. ? Werte ändern sich (Zufallswerte)
5. ? Stats zeigen korrekte Zahlen
6. ? Keine Fehler in den Logs
7. ? System läuft stabil über mehrere Minuten

---

## ?? Abschluss

Wenn alle Tests ? sind, funktioniert dein Multi-Station System perfekt!

**Nächste Schritte:**
- Experimentiere mit mehr Stationen (10+)
- Prüfe Aggregates-Seite
- Teste verschiedene Szenarien (Regen-Simulation)
