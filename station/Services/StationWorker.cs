using MeteoMesh.Lite.Proto;
using System.Collections.Concurrent;
using System.Threading;

public class StationWorker {
    private readonly StationIngress.StationIngressClient _client;
    private readonly string _id;
    private readonly Random _rnd = new();

    // shared state
    private volatile bool _isRaining = false;
    private double _currentPressure = 1013.25; // default

    public StationWorker(StationIngress.StationIngressClient client, string stationId) {
        _client = client; 
        _id = stationId;
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
        // Lidar detects rain intensity (0 = no rain, >0 = rain)
        var interval = TimeSpan.FromSeconds(2);
        var lastRainObserved = DateTimeOffset.MinValue;

        while (!token.IsCancellationRequested) {
            // Simulate rainfall probability
            var rain = _rnd.NextDouble() < 0.2 ? Math.Round(_rnd.NextDouble() * 5, 2) : 0.0; // mm
            await SendMeasurementAsync("lidar", rain);

            if (rain > 0) {
                _isRaining = true;
                lastRainObserved = DateTimeOffset.UtcNow;
            }
            else {
                // if no rain for 5 seconds, clear rain flag
                if (_isRaining && DateTimeOffset.UtcNow - lastRainObserved > TimeSpan.FromSeconds(5)) {
                    _isRaining = false;
                }
            }

            await Task.Delay(interval, token);
        }
    }

    private async Task RunHumiditySensorAsync(CancellationToken token) {
        var interval = TimeSpan.FromSeconds(4);

        while (!token.IsCancellationRequested) {
            if (_isRaining) {
                // skip humidity measurement during rain
                Console.WriteLine($"[{_id}] humidity skip due to rain");
                await Task.Delay(interval, token);
                continue;
            }

            var humidity = Math.Round(30 + _rnd.NextDouble() * 70, 1); // 30-100%
            await SendMeasurementAsync("humidity", humidity);

            await Task.Delay(interval, token);
        }
    }

    private async Task RunTemperatureSensorAsync(CancellationToken token) {
        var baseInterval = TimeSpan.FromSeconds(3);

        while (!token.IsCancellationRequested) {
            // adjust interval based on pressure
            var currentPressure = Volatile.Read(ref _currentPressure);
            var interval = (currentPressure > 950) ? TimeSpan.FromSeconds(baseInterval.TotalSeconds / 2) : baseInterval;

            var temp = Math.Round(15 + 10 * _rnd.NextDouble(), 1); // 15-25 C
            await SendMeasurementAsync("temperature", temp);

            await Task.Delay(interval, token);
        }
    }

    private async Task RunPressureSensorAsync(CancellationToken token) {
        var interval = TimeSpan.FromSeconds(5);

        while (!token.IsCancellationRequested) {
            // simulate pressure around typical sea-level values
            var pressure = Math.Round(980 + _rnd.NextDouble() * 70, 2); // 980-1050 hPa
            Volatile.Write(ref _currentPressure, pressure);
            await SendMeasurementAsync("pressure", pressure);

            await Task.Delay(interval, token);
        }
    }
}