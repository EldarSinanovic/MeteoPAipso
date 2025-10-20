# ? SCHNELLSTART - 2 Stationen anzeigen

## ?? Das Problem
Im Frontend siehst du nur **1 Station** (station-001).

## ? Die Lösung (1 Befehl!)

```powershell
.\scripts\fix-2-stations.ps1
```

**Das war's!** 

Nach 15 Sekunden:
1. Browser öffnet sich
2. Drücke **Ctrl + F5**
3. Beide Stationen sind sichtbar! ??

---

## ?? Alternative Methoden

### Methode 1: Nur zweite Station starten
```powershell
.\scripts\start-station-002.ps1
```

### Methode 2: Kompletter Neustart
```powershell
.\scripts\stop-all.ps1
.\scripts\start-all.ps1 -Stations 2
```

### Methode 3: Prüfen was läuft
```powershell
.\scripts\check-stations.ps1
```

---

## ? Erfolgs-Kriterien

Im Browser solltest du sehen:

```
??????????????????????????????
? Aktive Stationen: 2        ?
? Gesamt Sensoren: 8         ?
? Sensor Typen: 4            ?
??????????????????????????????
```

**Tabelle zeigt:**
- station-001 mit 4 Sensoren
- station-002 mit 4 Sensoren

---

## ?? Wenn es nicht funktioniert

1. **Prüfe PowerShell-Fenster der Stationen**
   - Siehst du `[station-002] sent ... ok=True`?
   - Wenn `ok=False` ? System neu starten

2. **Hard Refresh im Browser**
   ```
   Ctrl + F5
   ```

3. **System komplett neu starten**
   ```powershell
   .\scripts\stop-all.ps1
   .\scripts\start-all.ps1 -Stations 2
   ```

---

## ?? Los geht's!

```powershell
.\scripts\fix-2-stations.ps1
```

Warte 15 Sekunden, dann **Ctrl + F5** im Browser. Fertig! ?
