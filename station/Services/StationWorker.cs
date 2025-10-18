using MeteoMesh.Lite.Proto;

public class StationWorker {
    private readonly StationIngress.StationIngressClient _client;
    private readonly string _id;
    private readonly Random _rnd = new();

    public StationWorker(StationIngress.StationIngressClient client, string stationId) {
        _client = client; 
        _id = stationId;
    }

    public async Task RunAsync(CancellationToken ct) {
        while (!ct.IsCancellationRequested) {
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            var isRain = _rnd.NextDouble() < 0.3;
            var m = new Measurement {
                StationId = _id,
                Type = isRain ? "rain" : "temp",
                Value = isRain ? 1.0 : Math.Round(10 + _rnd.NextDouble() * 10, 1),
                Timestamp = now
            };
            var reply = await _client.SubmitMeasurementAsync(m);
            Console.WriteLine($"[{_id}] sent {m.Type}={m.Value} ok={reply.Ok}");
            await Task.Delay(2000, ct);
        }
    }
}