# ?? Problemlösung: Mehrere Stationen im Frontend anzeigen

## ? Das Problem

Du sahst nur **eine** Station im Frontend, obwohl mehrere Stationen liefen.

## ?? Die Ursache

Der `StationStore` speicherte nur die **letzte Messung pro Station**. Wenn Station-001 mehrere Sensoren hatte (Temperature, Humidity, Pressure, Lidar), wurde nur der **zuletzt gesendete Sensor** angezeigt.

**Vorher:**
```
Station-001 ? Temperature (zuletzt gesendet)
Station-002 ? Lidar (zuletzt gesendet)
```

Alle anderen Sensoren wurden **überschrieben**!

---

## ? Die Lösung

Ich habe den `StationStore` erweitert, um **alle Sensoren jeder Station** zu speichern:

### Änderung 1: StationStore erweitert

**Neu:** `SensorStatus` Record
```csharp
public record SensorStatus(
    string StationId, 
    string SensorType, 
    double Value, 
    long Timestamp, 
    string State
);
```

**Neue Datenstruktur:**
```csharp
// Alle Sensoren pro Station
private readonly Dictionary<string, Dictionary<string, SensorStatus>> _sensorMap = new();
```

**Neue Methode:**
```csharp
public List<SensorStatus> AllSensors()
{
    return _sensorMap.Values
        .SelectMany(sensors => sensors.Values)
        .OrderBy(s => s.StationId)
        .ThenBy(s => s.SensorType)
        .ToList();
}
```

### Änderung 2: LocalNodeDataService

**GetStations** gibt jetzt **alle Sensoren** zurück:

```csharp
public override Task<StationList> GetStations(...)
{
    var allSensors = _store.AllSensors(); // ALLE Sensoren!
    
    list.Items.AddRange(allSensors.Select(s => new Proto.StationStatus
    {
        StationId = s.StationId,
        LastType = s.SensorType,
        LastValue = s.Value,
        LastTs = s.Timestamp,
        State = s.State
    }));
    
    return Task.FromResult(list);
}
```

### Änderung 3: Frontend (Index.razor)

**Gruppierung nach Station:**

```csharp
// Gruppiere nach Station ID
_groupedItems = _items
    .GroupBy(s => s.StationId)
    .OrderBy(g => g.Key)
    .ToDictionary(
        g => g.Key, 
        g => g.OrderBy(s => s.LastType).ToList()
    );
```

**Neue Darstellung:**
```html
@foreach (var group in _groupedItems)
{
    <td rowspan="@group.Value.Count">
        <strong>@s.StationId</strong>
        <span>@group.Value.Count Sensoren</span>
    </td>
    <!-- Sensoren -->
}
```

### Änderung 4: CSS

Neue Styles für gruppierte Stationen:
- `.station-group-start` - Markiert Stationen-Gruppenbeginn
- `.station-id-cell` - Hervorgehobene Station-ID
- `.sensor-badge` - Schöne Sensor-Badges
- `.sensor-count` - Zeigt Anzahl der Sensoren

---

## ?? Ergebnis

**Vorher:**
```
??????????????????????????????????
?  Station-001  ?  Temperature  ?
??????????????????????????????????
```

**Nachher:**
```
?????????????????????????????????????????????????
?  Station-001     ?  temperature ?  18.5 °C   ?
?  (4 Sensoren)    ?  humidity    ?  65.2 %    ?
?                  ?  pressure    ?  1013 hPa  ?
?                  ?  lidar       ?  0.0 mm    ?
?????????????????????????????????????????????????
?  Station-002     ?  temperature ?  20.1 °C   ?
?  (4 Sensoren)    ?  humidity    ?  58.3 %    ?
?                  ?  pressure    ?  1015 hPa  ?
?                  ?  lidar       ?  1.2 mm    ?
?????????????????????????????????????????????????
```

---

## ?? So testest du es

### 1. System starten

```powershell
.\scripts\start-all.ps1 -Stations 2
```

### 2. Warten (ca. 10 Sekunden)

Die Stationen senden Daten in verschiedenen Intervallen:
- **Temperature**: alle 3 Sekunden
- **Humidity**: alle 4 Sekunden  
- **Pressure**: alle 5 Sekunden
- **Lidar**: alle 2 Sekunden

### 3. Browser öffnen

```
http://localhost:5000
```

### 4. Was du sehen solltest

**Stats oben:**
- ? Aktive Stationen: **2**
- ? Gesamt Sensoren: **8** (4 pro Station)
- ? Sensor Typen: **4**

**Tabelle:**
- ? Station-001 mit 4 Sensoren
- ? Station-002 mit 4 Sensoren
- ? Alle Werte aktualisieren sich

---

## ?? Troubleshooting

### Problem: Sehe immer noch nur eine Station

**Lösung 1:** Cache leeren
```powershell
# Strg+F5 im Browser (Hard Refresh)
# Oder:
Ctrl + Shift + R
```

**Lösung 2:** System neu starten
```powershell
.\scripts\stop-all.ps1
.\scripts\start-all.ps1 -Stations 2
```

**Lösung 3:** Prüfe ob beide Stationen laufen
```powershell
# Zeige alle dotnet Prozesse
Get-Process | Where-Object { $_.ProcessName -eq 'dotnet' }
```

Du solltest mindestens **4 Prozesse** sehen:
1. LocalNode
2. Central
3. Station-001
4. Station-002

### Problem: Stationen verbinden nicht

**Prüfe LocalNode:**
```powershell
curl http://localhost:5001
# Sollte antworten: "LocalNode up"
```

**Prüfe Station-Logs:**
Schau in die PowerShell-Fenster der Stationen. Du solltest sehen:
```
[station-001] sent temperature=18.5 ok=True
[station-001] sent humidity=65.2 ok=True
```

---

## ?? Zusammenfassung der Änderungen

| Datei | Änderung |
|-------|----------|
| `localnode\State\StationStore.cs` | ? Neue SensorStatus-Struktur, AllSensors() Methode |
| `localnode\Services\LocalNodeDataService.cs` | ? Verwendet AllSensors() statt All() |
| `central\Pages\Index.razor` | ? Gruppierung nach Stationen, Sensor-Zähler |
| `central\wwwroot\css\app.css` | ? Neue Styles für Gruppierung |

---

## ?? Fertig!

Dein System zeigt jetzt **alle Stationen mit allen Sensoren** korrekt an! ??
