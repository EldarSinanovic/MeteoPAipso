using MeteoMesh.Lite.Proto;

public class StationWorker {
    private readonly StationIngress.StationIngressClient _client;
    private readonly string _id;
    private readonly Random _rnd = new();
    private readonly MeasurementScheduler _scheduler;

    public StationWorker(StationIngress.StationIngressClient client, string stationId, IClock? clock = null) {
        _client = client;
        _id = stationId;
        _scheduler = new MeasurementScheduler(clock);
    }

    public async Task RunAsync(CancellationToken ct) {
        var tasks = new List<Task> {
            Task.Run(() => RunLidarSensorAsync(ct), ct),
            Task.Run(() => RunHumiditySensorAsync(ct), ct),
            Task.Run(() => RunTemperatureSensorAsync(ct), ct),
            Task.Run(() => RunPressureSensorAsync(ct), ct)
        };

        try {
            await Task.WhenAll(tasks);
        }
        catch (OperationCanceledException) when (ct.IsCancellationRequested) {
            // expected on shutdown
        }
    }

    private async Task SendMeasurementAsync(string type, double value) {
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
        var m = new Measurement {
            StationId = _id,
            Type = type,
            Value = value,
            Timestamp = now
        };

        try {
            var reply = await _client.SubmitMeasurementAsync(m);
            Console.WriteLine($"[{_id}] sent {m.Type}={m.Value} ok={reply.Ok}");
        }
        catch (Exception ex) {
            Console.WriteLine($"[{_id}] failed to send {type}: {ex.Message}");
        }
    }

    private async Task RunLidarSensorAsync(CancellationToken token) {
        while (!token.IsCancellationRequested) {
            var rain = _rnd.NextDouble() < 0.2 ? Math.Round(_rnd.NextDouble() * 5, 2) : 0.0; // mm
            await SendMeasurementAsync("lidar", rain);

            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            _scheduler.Coordinator.ObserveLidar(rain, now);

            await _scheduler.WaitForNextMeasurement("lidar", token);
        }
    }

    private async Task RunHumiditySensorAsync(CancellationToken token) {
        while (!token.IsCancellationRequested) {
            var shouldMeasure = await _scheduler.WaitForNextMeasurement("humidity", token);
            if (!shouldMeasure)
            {
                Console.WriteLine($"[{_id}] humidity skip due to rain");
                continue;
            }

            var humidity = Math.Round(30 + _rnd.NextDouble() * 70, 1); // 30-100%
            await SendMeasurementAsync("humidity", humidity);
        }
    }

    private async Task RunTemperatureSensorAsync(CancellationToken token) {
        while (!token.IsCancellationRequested) {
            var temp = Math.Round(15 + 10 * _rnd.NextDouble(), 1); // 15-25 C
            await SendMeasurementAsync("temperature", temp);

            await _scheduler.WaitForNextMeasurement("temperature", token);
        }
    }

    private async Task RunPressureSensorAsync(CancellationToken token) {
        while (!token.IsCancellationRequested) {
            var pressure = Math.Round(980 + _rnd.NextDouble() * 70, 2); // 980-1050 hPa
            _scheduler.Coordinator.UpdatePressure(pressure);
            await SendMeasurementAsync("pressure", pressure);

            await _scheduler.WaitForNextMeasurement("pressure", token);
        }
    }
}