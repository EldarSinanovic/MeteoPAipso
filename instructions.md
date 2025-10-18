# instructions.md

## Ziel

Erzeuge mit **VS Code + GitHub Copilot** einen **Minimal-Prototyp MeteoMesh (Lite)**:

- **Central** (Blazor Server, *eine Seite*): Liste aller Stationen mit letztem Messwert & Status  
- **LocalNode** (Console): nimmt Messwerte entgegen, speichert In-Memory, gibt Daten/Status aus  
- **StationWorker** (Console): simuliert Messwerte und sendet sie periodisch an den LocalNode  
- **Kommunikation**: gRPC (leichtgewichtig), **keine** Datenbank, **keine** Auth  
- **Logs**: Serilog in allen Prozessen

> Fokus: *einfach*, *lesbar*, *startbar in <5 Minuten*, *klarer Pfad zur Erweiterung*.

---

## Projektstruktur (Zielsoll)

```
MeteoMesh.Lite/
  MeteoMesh.Lite.sln
  central/                  # Blazor Server (eine Seite: Übersicht)
    Program.cs
    Pages/Index.razor
    Services/LocalNodeClient.cs
    Protos/measurement.proto
    appsettings.json
  localnode/                # Console: gRPC-Host + In-Memory-Store
    Program.cs
    Services/StationIngressService.cs
    Services/LocalNodeDataService.cs
    Services/StationControlService.cs (nur Stub)
    State/StationStore.cs
    Protos/measurement.proto
    appsettings.json
  station/                  # Console: simuliert StationWorker
    Program.cs
    Services/StationWorker.cs
    Protos/measurement.proto
    appsettings.json
  shared/                   # optional (gemeinsame Modelle/Enums)
    Models.cs
  README.md                 # Kurzanleitung (Start/Run)
  instructions.md           # diese Datei
```

---

## Vorbereitungen

1. **.NET installieren** (8 oder 9)  
2. VS Code Extensions:  
   - *C# Dev Kit* oder *C#*  
   - *GitHub Copilot*  
   - *gRPC* (optional)

---

## Schritt 1 – Lösung & Projekte anlegen (Copilot-Prompts)

Öffne VS Code-Terminal und erstelle Sln & Projekte. Du kannst Copilot bitten, dir die passenden Befehle zu schreiben – oder direkt diese nutzen:

```bash
mkdir MeteoMesh.Lite && cd MeteoMesh.Lite
dotnet new sln -n MeteoMesh.Lite

dotnet new blazorserver -n central
dotnet new console -n localnode
dotnet new console -n station

dotnet new classlib -n shared

dotnet sln add central/central.csproj localnode/localnode.csproj station/station.csproj shared/shared.csproj
dotnet add central reference shared
dotnet add localnode reference shared
dotnet add station reference shared
```

**Copilot-Prompt (Chat im VS Code):**

> „Erzeuge eine .NET Sln mit Projekten *central (blazorserver)*, *localnode (console)*, *station (console)* und *shared (classlib)*. Füge Referenzen zu *shared* hinzu. Setze TargetFramework `net8.0` oder `net9.0` konsistent.“

---

## Schritt 2 – Proto definieren (einfach)

`central/Protos/measurement.proto` (kopiere identisch auch nach `localnode/Protos/measurement.proto` und `station/Protos/measurement.proto`):

```proto
syntax = "proto3";
option csharp_namespace = "MeteoMesh.Lite.Proto";

package meteo;

message Measurement {
  string stationId = 1;
  string type = 2;        // "temp" | "humidity" | "pressure" | "rain"
  double value = 3;
  int64  timestamp = 4;   // unix ms
}

message SubmitReply { bool ok = 1; }

message QueryRequest {}
message StationStatus {
  string stationId = 1;
  string lastType = 2;
  double lastValue = 3;
  int64  lastTs = 4;
  string state = 5;       // "Active" | "Inactive" | "Suspended"
}
message StationList { repeated StationStatus items = 1; }

service StationIngress {
  rpc SubmitMeasurement(Measurement) returns (SubmitReply);
}

service LocalNodeData {
  rpc GetStations(QueryRequest) returns (StationList);
}

message CommandRequest { string stationId = 1; string command = 2; }
message CommandReply { bool ok = 1; }

service StationControl {
  rpc SendCommand(CommandRequest) returns (CommandReply);
}
```

**Copilot-Prompt:**

> „Erzeuge mir für gRPC in C# die Server- und Client-Stubs aus `Protos/measurement.proto` in den Projekten *localnode*, *central* und *station*. Nutze Grpc.AspNetCore im Host, Grpc.Net.Client im Client.“

**Pakete hinzufügen (Terminal):**
```bash
dotnet add localnode package Grpc.AspNetCore
dotnet add station package Grpc.Net.Client
dotnet add central package Grpc.Net.Client
dotnet add central package Microsoft.AspNetCore.Components.Authorization
dotnet add central package Serilog.AspNetCore
dotnet add station package Serilog.Sinks.Console
dotnet add localnode package Serilog.AspNetCore
```

---

## Schritt 3 – LocalNode (Console, gRPC-Host, In-Memory-Store)

**Ziel:** gRPC-Server auf `http://localhost:5001` hosten, Messwerte empfangen, letzten Status je Station speichern, einfache Regel anwenden.

**State/StationStore.cs (Beispiel):**
```csharp
public record StationStatus(string StationId, string LastType, double LastValue, long LastTs, string State);

public class StationStore {
    private readonly Dictionary<string, StationStatus> _map = new();
    private readonly object _lock = new();

    public void Upsert(StationStatus s) { lock(_lock) { _map[s.StationId] = s; } }
    public List<StationStatus> All() { lock(_lock) { return _map.Values.ToList(); } }
    public StationStatus? Get(string id) { lock(_lock) { return _map.TryGetValue(id, out var v) ? v : null; } }
}
```

**Services/StationIngressService.cs (Kernlogik, Pseudocode):**
```csharp
public class StationIngressService : meteo.StationIngress.StationIngressBase {
    private readonly StationStore _store;
    public StationIngressService(StationStore store) => _store = store;

    public override Task<SubmitReply> SubmitMeasurement(Measurement m, ServerCallContext ctx) {
        // einfache Regel: wenn type = "rain" und value > 0 -> markiere Humidity als "Suspended"
        var state = "Active";
        if (m.Type == "rain" && m.Value > 0) state = "Suspended";

        _store.Upsert(new StationStatus(
            m.StationId, m.Type, m.Value, m.Timestamp, state
        ));
        Console.WriteLine($"[Ingress] {m.StationId} {m.Type}={m.Value} state={state}");
        return Task.FromResult(new SubmitReply { Ok = true });
    }
}
```

**Services/LocalNodeDataService.cs:**
```csharp
public class LocalNodeDataService : meteo.LocalNodeData.LocalNodeDataBase {
    private readonly StationStore _store;
    public LocalNodeDataService(StationStore store) => _store = store;

    public override Task<StationList> GetStations(QueryRequest req, ServerCallContext ctx) {
        var list = new StationList();
        list.Items.AddRange(_store.All().Select(s => new meteo.StationStatus {
            StationId = s.StationId, LastType = s.LastType, LastValue = s.LastValue,
            LastTs = s.LastTs, State = s.State
        }));
        return Task.FromResult(list);
    }
}
```

**Program.cs (minimaler gRPC-Host + Serilog):**
```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Host.UseSerilog((ctx, lc) => lc.WriteTo.Console());

builder.Services.AddSingleton<StationStore>();
builder.Services.AddGrpc();

var app = builder.Build();
app.MapGrpcService<StationIngressService>();
app.MapGrpcService<LocalNodeDataService>();
app.MapGet("/", () => "LocalNode up");
app.Run("http://localhost:5001");
```

**Copilot-Prompt:**

> „Erstelle mir im *localnode*-Projekt einen gRPC-Host, registriere `StationIngressService` und `LocalNodeDataService`, nutze Serilog Console Logging, und starte auf `http://localhost:5001`. “

---

## Schritt 4 – Station (Console, Sender)

**Services/StationWorker.cs (Loop):**
```csharp
public class StationWorker {
    private readonly meteo.StationIngress.StationIngressClient _client;
    private readonly string _id;
    private readonly Random _rnd = new();

    public StationWorker(meteo.StationIngress.StationIngressClient client, string stationId) {
        _client = client; _id = stationId;
    }

    public async Task RunAsync(CancellationToken ct) {
        while (!ct.IsCancellationRequested) {
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            // einfache Rotation: temp und rain im Wechsel
            var isRain = _rnd.NextDouble() < 0.3;
            var m = new Measurement {
                StationId = _id,
                Type = isRain ? "rain" : "temp",
                Value = isRain ? 1.0 : Math.Round(10 + _rnd.NextDouble()*10, 1),
                Timestamp = now
            };
            var reply = await _client.SubmitMeasurementAsync(m);
            Console.WriteLine($"[{_id}] sent {m.Type}={m.Value} ok={reply.Ok}");
            await Task.Delay(2000, ct);
        }
    }
}
```

**Program.cs (Client + Start):**
```csharp
using Grpc.Net.Client;
using MeteoMesh.Lite.Proto;

var ch = GrpcChannel.ForAddress("http://localhost:5001");
var client = new StationIngress.StationIngressClient(ch);
var worker = new StationWorker(client, args.FirstOrDefault() ?? "station-001");

var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) => { e.Cancel = true; cts.Cancel(); };

await worker.RunAsync(cts.Token);
```

**Copilot-Prompt:**

> „Erstelle eine einfache StationWorker-Klasse, die alle 2 Sekunden wahlweise `rain` oder `temp` sendet. Wenn `rain` gesendet wird (value > 0), soll der LocalNode die Station als `Suspended` markieren.“

---

## Schritt 5 – Central (Blazor Server, *eine Seite*)

**Services/LocalNodeClient.cs (gRPC-Client):**
```csharp
using Grpc.Net.Client;
using MeteoMesh.Lite.Proto;

public class LocalNodeClient {
    private readonly LocalNodeData.LocalNodeDataClient _client;
    public LocalNodeClient() {
        var ch = GrpcChannel.ForAddress("http://localhost:5001");
        _client = new LocalNodeData.LocalNodeDataClient(ch);
    }
    public async Task<IReadOnlyList<StationStatus>> GetStationsAsync() {
        var resp = await _client.GetStationsAsync(new QueryRequest());
        return resp.Items;
    }
}
```

**Program.cs (DI + Razor):**
```csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();
builder.Services.AddSingleton<LocalNodeClient>();
var app = builder.Build();
app.MapBlazorHub();
app.MapFallbackToPage("/_Host");
app.Run();
```

**Pages/Index.razor (Single Page Übersicht):**
```razor
@page "/"
@inject LocalNodeClient Client

<h3>MeteoMesh – Übersicht</h3>

@if (_items is null)
{
    <p>Lade...</p>
}
else
{
    <table>
        <thead>
            <tr><th>Station</th><th>Typ</th><th>Wert</th><th>Timestamp</th><th>Status</th></tr>
        </thead>
        <tbody>
        @foreach (var s in _items)
        {
            <tr>
                <td>@s.StationId</td>
                <td>@s.LastType</td>
                <td>@s.LastValue</td>
                <td>@DateTimeOffset.FromUnixTimeMilliseconds(s.LastTs).ToLocalTime()</td>
                <td>@s.State</td>
            </tr>
        }
        </tbody>
    </table>
}

@code {
    List<MeteoMesh.Lite.Proto.StationStatus>? _items;
    protected override async Task OnInitializedAsync() =>
        _items = (await Client.GetStationsAsync()).ToList();
}
```

**Copilot-Prompt:**

> „Erzeuge in Blazor Server eine einzelne Seite `Index.razor`, die per gRPC `GetStations()` beim LocalNode abruft und eine Tabelle mit StationId, LastType, LastValue, Timestamp (lokal formatiert) und State rendert.“

---

## Schritt 6 – Start & Test

**Terminal 1 – LocalNode:**
```bash
dotnet run --project localnode
```

**Terminal 2 – Station (optional mehrere Instanzen):**
```bash
dotnet run --project station -- station-001
dotnet run --project station -- station-002
```

**Terminal 3 – Central (Blazor):**
```bash
dotnet run --project central
```
Öffne die Konsole/URL, die VS Code ausgibt (Blazor-Dev-Server).  
Du siehst **eine Tabelle** mit **aktiven Stationen**; wenn `rain` gesendet wird, steht der **State = Suspended**.

---

## Akzeptanzkriterien (Definition of Done)

- [ ] **LocalNode** läuft als Console, gibt Logs aus, nimmt gRPC `SubmitMeasurement` an, liefert `GetStations` zurück  
- [ ] **Station** sendet alle 2s Messwerte; Logs zeigen „sent … ok=true“  
- [ ] **Regel**: `rain > 0` → Station `Suspended` im Store und sichtbar in Central  
- [ ] **Central** zeigt *eine* Seite (Index) mit Tabelle aller Stationen und letztem Messwert  
- [ ] **Kein** DB-Setup, **keine** Auth, **keine** komplexen Pipelines  
- [ ] Starten & stoppen ohne Exceptions

---

## Erweiterungen (optional, nachträglich)

- **Druck-Regel**: Pressure > 950 hPa → „Temp-Intervall 7.5 min“ simulieren (nur Anzeigehinweis)  
- **StationControl**: Button in Central → SendCommand an Station (Stub ok)  
- **Docker**: drei Services in `docker-compose.yml`  
- **Monitoring**: Timing-Logs mit Log-Scopes (Serilog enricher)

---

## Nützliche Copilot-Prompts (Copy/Paste)

- „Schreibe mir eine C#-gRPC-Serviceklasse `LocalNodeDataService` mit Methode `GetStations`, die Daten aus einem InMemory-Store zurückgibt (Liste aus `StationStatus`).“
- „Erzeuge eine Blazor Server Seite `Index.razor`, die per DI einen gRPC-Client nutzt, um `GetStations` aufzurufen und die Ergebnisse in einer HTML-Tabelle anzuzeigen.“
- „Implementiere eine Console-App, die alle 2 Sekunden zufällig `temp` oder `rain` per gRPC an `http://localhost:5001` sendet (StationId über CLI-Argument).“
- „Füge Serilog Console Logging in die Projekte ein (Program.cs) und schreibe je Action einen Logeintrag.“

---

## Troubleshooting

- **Port-Kollision**: Blazor und gRPC-Host dürfen nicht denselben Port nutzen. LocalNode im Beispiel: `http://localhost:5001`; Blazor nimmt Standard (z. B. 5242/7063).  
- **HTTP/2 (gRPC)**: Für `Grpc.Net.Client` im Development reicht `http://` (unverschlüsselt) – bei TLS `https://` + Kestrel/Cert konfigurieren.  
- **Proto Sync**: Achte darauf, dass alle drei Projekte dieselbe `measurement.proto` nutzen oder generierte Stubs in `shared` auslagern.

---

Viel Erfolg!