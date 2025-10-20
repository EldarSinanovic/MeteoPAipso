using Grpc.Net.Client;
using MeteoIpso.Proto;
using MeteoIpso.Station;

var ch = GrpcChannel.ForAddress("http://localhost:5001");
var client = new StationIngress.StationIngressClient(ch);
var worker = new StationWorker(client, args.FirstOrDefault() ?? "station-001");

var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) => { e.Cancel = true; cts.Cancel(); };

await worker.RunAsync(cts.Token);