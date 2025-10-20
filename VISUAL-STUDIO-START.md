# ?? Visual Studio - 2 Stationen starten (EINFACH!)

## ? Die L�sung - Mit .NET Aspire Host

Du hast bereits **Host.AppHost** in deiner Solution - das ist perfekt!

### **So funktioniert es jetzt:**

1. **Setze `Host.AppHost` als Startup Project**
   - Im **Solution Explorer**
   - **Rechtsklick** auf `Host.AppHost`
   - **"Set as Startup Project"**

2. **Dr�cke F5 oder klicke auf "Start"**

3. **FERTIG!** ??
   - Es �ffnet sich das **Aspire Dashboard**
   - Dort siehst du alle laufenden Komponenten:
     - ? localnode
     - ? central
     - ? station-001
     - ? station-002

4. **�ffne Central:**
   - Im Aspire Dashboard auf **central** klicken
   - Oder direkt: http://localhost:5000
   - Du siehst **2 Stationen**! ??

---

## ?? Was ich ge�ndert habe

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

## ?? Schritt-f�r-Schritt

### 1. Startup Project setzen

**Visual Studio:**
1. Solution Explorer �ffnen
2. Rechtsklick auf `Host.AppHost`
3. "Set as Startup Project"
4. Das Projekt wird **fett** dargestellt

### 2. Starten

- **F5** dr�cken
- ODER **Debug** ? **Start Debugging**
- ODER gr�ner **Play-Button** ??

### 3. Aspire Dashboard �ffnet sich

Du siehst eine �bersicht:

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

### 4. Central �ffnen

- Im Dashboard auf **central** klicken
- Link: http://localhost:5000
- Browser �ffnet sich

### 5. Frontend pr�fen

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
- **F5** dr�cken ? Alle 4 Komponenten starten automatisch
- **Kein Script** mehr n�tig!
- **Kein Terminal** mehr n�tig!
- **Alles in Visual Studio**!

---

## ?? Bonus: Mehr Stationen

Willst du 3 Stationen? Bearbeite `Host\Host.AppHost\Program.cs`:

```csharp
// Station 3 hinzuf�gen
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
- ? **Links** zu Services �ffnen (z.B. Central)
- ? Services **neu starten**

---

## ? Probleml�sung

### Problem: "Projects not found"

**L�sung:** Build die Solution erst:
```
Build ? Rebuild Solution
```

Dann **F5**

### Problem: Port bereits belegt

**L�sung:** Beende alle dotnet-Prozesse:
```
Ctrl + Shift + Esc ? dotnet.exe ? End Task
```

Dann **F5**

---

## ? Zusammenfassung

**VORHER:**
- ? Scripts ausf�hren
- ? 4 separate PowerShell-Fenster
- ? Manuell starten/stoppen

**JETZT:**
- ? **F5** dr�cken
- ? Alle Komponenten starten
- ? Aspire Dashboard �ffnet sich
- ? 2 Stationen automatisch sichtbar

**Das war's!** ??
