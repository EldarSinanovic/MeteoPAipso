# ?? Visual Studio - 2 Stationen starten (EINFACH!)

## ? Die Lösung - Mit .NET Aspire Host

Du hast bereits **Host.AppHost** in deiner Solution - das ist perfekt!

### **So funktioniert es jetzt:**

1. **Setze `Host.AppHost` als Startup Project**
   - Im **Solution Explorer**
   - **Rechtsklick** auf `Host.AppHost`
   - **"Set as Startup Project"**

2. **Drücke F5 oder klicke auf "Start"**

3. **FERTIG!** ??
   - Es öffnet sich das **Aspire Dashboard**
   - Dort siehst du alle laufenden Komponenten:
     - ? localnode
     - ? central
     - ? station-001
     - ? station-002

4. **Öffne Central:**
   - Im Aspire Dashboard auf **central** klicken
   - Oder direkt: http://localhost:5000
   - Du siehst **2 Stationen**! ??

---

## ?? Was ich geändert habe

### `Host\Host.AppHost\Program.cs`:

```csharp
// LocalNode - gRPC Server
var localnode = builder.AddProject<Projects.localnode>("localnode")
    .WithHttpEndpoint(port: 5001, name: "grpc");

// Central - Blazor UI  
var central = builder.AddProject<Projects.central>("central")
    .WithReference(localnode)
    .WithHttpEndpoint(port: 5000, name: "http");

// Station 1
builder.AddProject<Projects.station>("station-001")
    .WithReference(localnode)
    .WithArgs("station-001");

// Station 2
builder.AddProject<Projects.station>("station-002")
    .WithReference(localnode)
    .WithArgs("station-002");
```

**Das startet automatisch:**
- ? 1x LocalNode (Port 5001)
- ? 1x Central (Port 5000)
- ? 2x Station (station-001 und station-002)

---

## ?? Schritt-für-Schritt

### 1. Startup Project setzen

**Visual Studio:**
1. Solution Explorer öffnen
2. Rechtsklick auf `Host.AppHost`
3. "Set as Startup Project"
4. Das Projekt wird **fett** dargestellt

### 2. Starten

- **F5** drücken
- ODER **Debug** ? **Start Debugging**
- ODER grüner **Play-Button** ??

### 3. Aspire Dashboard öffnet sich

Du siehst eine Übersicht:

```
???????????????????????????????????????
? Aspire Dashboard                    ?
???????????????????????????????????????
? ? localnode      | Running         ?
? ? central        | Running         ?
? ? station-001    | Running         ?
? ? station-002    | Running         ?
???????????????????????????????????????
```

### 4. Central öffnen

- Im Dashboard auf **central** klicken
- Link: http://localhost:5000
- Browser öffnet sich

### 5. Frontend prüfen

Du solltest sehen:
```
??????????????????????????????
? Aktive Stationen: 2        ?
? Gesamt Sensoren: 8         ?
? Sensor Typen: 4            ?
??????????????????????????????
```

**Tabelle zeigt:**
- station-001 (4 Sensoren)
- station-002 (4 Sensoren)

---

## ?? FERTIG!

**Ab jetzt:**
- **F5** drücken ? Alle 4 Komponenten starten automatisch
- **Kein Script** mehr nötig!
- **Kein Terminal** mehr nötig!
- **Alles in Visual Studio**!

---

## ?? Bonus: Mehr Stationen

Willst du 3 Stationen? Bearbeite `Host\Host.AppHost\Program.cs`:

```csharp
// Station 3 hinzufügen
builder.AddProject<Projects.station>("station-003")
    .WithReference(localnode)
    .WithArgs("station-003");
```

Speichern ? **F5** ? 3 Stationen laufen! ??

---

## ?? Aspire Dashboard Features

Im Dashboard kannst du:
- ? **Logs** von jedem Service sehen
- ? **Metriken** anzeigen
- ? **Traces** verfolgen
- ? **Links** zu Services öffnen (z.B. Central)
- ? Services **neu starten**

---

## ? Problemlösung

### Problem: "Projects not found"

**Lösung:** Build die Solution erst:
```
Build ? Rebuild Solution
```

Dann **F5**

### Problem: Port bereits belegt

**Lösung:** Beende alle dotnet-Prozesse:
```
Ctrl + Shift + Esc ? dotnet.exe ? End Task
```

Dann **F5**

---

## ? Zusammenfassung

**VORHER:**
- ? Scripts ausführen
- ? 4 separate PowerShell-Fenster
- ? Manuell starten/stoppen

**JETZT:**
- ? **F5** drücken
- ? Alle Komponenten starten
- ? Aspire Dashboard öffnet sich
- ? 2 Stationen automatisch sichtbar

**Das war's!** ??
