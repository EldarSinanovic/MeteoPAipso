# ?? Lösung: Zweite Station im Frontend sichtbar machen

## ?? Problem
Du siehst nur **station-001** im Frontend, aber **station-002** fehlt.

---

## ? Schritt-für-Schritt Lösung

### **Schritt 1: System komplett stoppen**

```powershell
# Im Projekt-Root-Verzeichnis
cd C:\Users\sinan\source\repos\MeteoPAipso

# Alle Prozesse beenden
.\scripts\stop-all.ps1
```

**Warte 3 Sekunden**, bis alle Prozesse beendet sind.

---

### **Schritt 2: Diagnose ausführen**

```powershell
# Prüfe den System-Status
.\scripts\diagnose.ps1
```

**Erwartete Ausgabe:**
```
??????????????????????????????????????????????????
?  MeteoIpso - System Diagnose                  ?
??????????????????????????????????????????????????

[1/6] Prüfe laufende Prozesse...
  ? FEHLER: Keine MeteoIpso-Prozesse laufen!
```

Das ist OK - wir haben gerade alles gestoppt!

---

### **Schritt 3: System mit 2 Stationen neu starten**

```powershell
# Starte mit GENAU 2 Stationen
.\scripts\start-all.ps1 -Stations 2
```

**Es sollten sich 4 PowerShell-Fenster öffnen:**
1. ??? **LocalNode** (Port 5001)
2. ?? **Central** (Port 5000)
3. ?? **Station-001**
4. ?? **Station-002**

**Der Browser öffnet automatisch:** http://localhost:5000

---

### **Schritt 4: Warte 15 Sekunden**

Die Stationen brauchen Zeit, um Daten zu senden:
- **Lidar**: alle 2 Sekunden
- **Temperature**: alle 3 Sekunden
- **Humidity**: alle 4 Sekunden
- **Pressure**: alle 5 Sekunden

Nach 15 Sekunden haben beide Stationen mindestens 1-2 Messungen pro Sensor gesendet.

---

### **Schritt 5: Prüfe die Station-Logs**

#### **Station-001 Fenster sollte zeigen:**
```
????????????????????????????????????
  Station: station-001
  LocalNode: http://localhost:5001
????????????????????????????????????

[station-001] sent lidar=0.0 ok=True
[station-001] sent temperature=18.5 ok=True
[station-001] sent humidity=65.2 ok=True
[station-001] sent pressure=1013.4 ok=True
```

#### **Station-002 Fenster sollte zeigen:**
```
????????????????????????????????????
  Station: station-002
  LocalNode: http://localhost:5001
????????????????????????????????????

[station-002] sent lidar=1.2 ok=True
[station-002] sent temperature=20.1 ok=True
[station-002] sent humidity=58.3 ok=True
[station-002] sent pressure=1015.2 ok=True
```

**?? WICHTIG:** Wenn `ok=False` erscheint, gibt es ein Problem!

---

### **Schritt 6: Prüfe LocalNode-Logs**

Im **LocalNode** PowerShell-Fenster solltest du sehen:

```
[Ingress] station-001 lidar=0.0 state=Active
[Ingress] station-001 temperature=18.5 state=Active
[Ingress] station-002 lidar=1.2 state=Active
[Ingress] station-002 temperature=20.1 state=Active
```

**? Beide Stationen senden Daten!**

---

### **Schritt 7: Frontend prüfen**

Gehe zu: **http://localhost:5000**

**Drücke `Ctrl + F5`** (Hard Refresh) um den Cache zu leeren.

#### **Du solltest JETZT sehen:**

```
?????????????????????????????????????????????
? ?? Debug Info:                            ?
?  • Gesamt Einträge: 8                     ?
?  • Eindeutige Stationen: 2                ?
?  • Station IDs: station-001, station-002  ?
?  • Letzte Aktualisierung: 22:15:30        ?
?  • Auto-Refresh: AN                       ?
?????????????????????????????????????????????
```

**Statistics:**
- Aktive Stationen: **2** ?
- Gesamt Sensoren: **8** ? (4 pro Station)
- Sensor Typen: **4** ?

**Tabelle:**
```
???????????????????????????????????????????????????????
? Station ID  ? Sensor Typ   ? Messwert  ? Status     ?
???????????????????????????????????????????????????????
? station-001 ? humidity     ?  65.2 %   ? ACTIVE     ?
? (4 Sensoren)? lidar        ?  0.0 mm   ? ACTIVE     ?
?             ? pressure     ? 1013 hPa  ? ACTIVE     ?
?             ? temperature  ?  18.5 °C  ? ACTIVE     ?
???????????????????????????????????????????????????????
? station-002 ? humidity     ?  58.3 %   ? ACTIVE     ?
? (4 Sensoren)? lidar        ?  1.2 mm   ? ACTIVE     ?
?             ? pressure     ? 1015 hPa  ? ACTIVE     ?
?             ? temperature  ?  20.1 °C  ? ACTIVE     ?
???????????????????????????????????????????????????????
```

---

## ?? Troubleshooting

### Problem 1: Immer noch nur 1 Station sichtbar

#### **Lösung A: Diagnose ausführen**
```powershell
.\scripts\diagnose.ps1 -Verbose
```

Prüfe die Ausgabe!

#### **Lösung B: Manuell zweite Station starten**

Öffne ein **NEUES PowerShell-Fenster**:
```powershell
cd C:\Users\sinan\source\repos\MeteoPAipso
dotnet run --project station -- station-002
```

Du solltest sehen:
```
[station-002] sent temperature=20.1 ok=True
```

#### **Lösung C: Browser-Cache leeren**
```
Ctrl + Shift + Delete
? "Cached images and files"
? Clear data
```

Dann: **Ctrl + F5**

---

### Problem 2: "ok=False" in Station-Logs

**Ursache:** Validation schlägt fehl

**Prüfe LocalNode-Logs** für Details:
```
[Ingress] station-002 temperature=150.0 rejected: Value out of range
```

**Lösung:** System neu starten
```powershell
.\scripts\stop-all.ps1
.\scripts\start-all.ps1 -Stations 2
```

---

### Problem 3: Station-002 Prozess läuft nicht

**Prüfe mit Diagnose:**
```powershell
.\scripts\diagnose.ps1
```

Wenn nur 1 Station läuft, starte manuell:
```powershell
dotnet run --project station -- station-002
```

---

### Problem 4: "Debug Info" zeigt nur 1 Station

**Option 1: Auto-Refresh warten**
Die Seite aktualisiert sich alle 5 Sekunden automatisch.

**Option 2: Manuell refreshen**
Klicke auf den **?? Aktualisieren** Button.

**Option 3: Hard Refresh**
```
Ctrl + F5
```

---

## ?? Erwartete Werte nach erfolgreichem Start

### **Im Browser (Debug Info):**
- ? Gesamt Einträge: **8**
- ? Eindeutige Stationen: **2**
- ? Station IDs: **station-001, station-002**
- ? Auto-Refresh: **AN**

### **In Station-Logs:**
- ? `[station-001] sent <sensor>=<value> ok=True`
- ? `[station-002] sent <sensor>=<value> ok=True`

### **In LocalNode-Logs:**
- ? `[Ingress] station-001 <sensor>=<value> state=Active`
- ? `[Ingress] station-002 <sensor>=<value> state=Active`

### **Im PowerShell (Prozesse):**
```powershell
Get-Process | Where-Object { $_.ProcessName -eq 'dotnet' }
```
**Sollte mindestens 4 Prozesse zeigen!**

---

## ?? Quick Check Command

```powershell
# Alles in einem:
.\scripts\diagnose.ps1

# Wenn Probleme gefunden werden:
.\scripts\stop-all.ps1
Start-Sleep -Seconds 3
.\scripts\start-all.ps1 -Stations 2

# Warte 15 Sekunden
Start-Sleep -Seconds 15

# Öffne Browser
Start-Process "http://localhost:5000"
```

---

## ? Erfolgs-Checkliste

Nach dem Start solltest du:

- ?? **4 PowerShell-Fenster** sehen (LocalNode, Central, 2 Stationen)
- ?? **"ok=True"** in beiden Station-Logs sehen
- ?? **Beide StationIds** in LocalNode-Logs sehen
- ?? **"Eindeutige Stationen: 2"** im Browser sehen
- ?? **8 Sensor-Einträge** in der Tabelle sehen
- ?? **Auto-Refresh funktioniert** (Zeitstempel ändert sich)

---

## ?? Pro-Tipp

**PowerShell-Fenster nebeneinander anordnen:**

1. Drücke `Win + ?` für LocalNode-Fenster (links)
2. Drücke `Win + ?` für Station-001 (rechts oben)
3. Arrangiere Station-002 (rechts unten)
4. Central läuft im Hintergrund

So siehst du alle Logs gleichzeitig! ??

---

## ?? Wenn alles funktioniert

**Experimentiere!**

```powershell
# Starte mit 5 Stationen
.\scripts\start-all.ps1 -Stations 5

# Oder 10!
.\scripts\start-all.ps1 -Stations 10
```

Viel Erfolg! ??
