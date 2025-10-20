using System;

public interface IClock
{
    DateTimeOffset UtcNow { get; }
    Task Delay(TimeSpan delay, CancellationToken ct = default);
}

public class SystemClock : IClock
{
    public DateTimeOffset UtcNow => DateTimeOffset.UtcNow;
    public Task Delay(TimeSpan delay, CancellationToken ct = default) => Task.Delay(delay, ct);
}

// Configurable measurement intervals and sync rules
public class MeasurementScheduler
{
    private readonly IClock _clock;
    private readonly SensorCoordinator _coordinator;
    private static readonly TimeSpan DefaultInterval = TimeSpan.FromMinutes(15); // default 15min

    private static readonly Dictionary<string, TimeSpan> SensorIntervals = new()
    {
        ["lidar"] = TimeSpan.FromMinutes(5),     // rain detection needs to be more frequent
        ["humidity"] = DefaultInterval,           // 15min default
        ["temperature"] = DefaultInterval,        // 15min but can be halved based on pressure
        ["pressure"] = DefaultInterval           // 15min default
    };

    public MeasurementScheduler(IClock? clock = null, SensorCoordinator? coordinator = null)
    {
        _clock = clock ?? new SystemClock();
        _coordinator = coordinator ?? new SensorCoordinator();
    }

    public SensorCoordinator Coordinator => _coordinator;

    public async Task<bool> WaitForNextMeasurement(string sensorType, CancellationToken ct)
    {
        if (!SensorIntervals.TryGetValue(sensorType, out var baseInterval))
        {
            baseInterval = DefaultInterval;
        }

        // Apply sync rules
        if (sensorType == "humidity" && _coordinator.ShouldSkipHumidity())
        {
            await _clock.Delay(baseInterval, ct);
            return false; // skip measurement
        }

        var interval = sensorType == "temperature" 
            ? _coordinator.GetTemperatureInterval(baseInterval)
            : baseInterval;

        await _clock.Delay(interval, ct);
        return true; // do measure
    }

    public static TimeSpan GetBaseInterval(string sensorType)
        => SensorIntervals.TryGetValue(sensorType, out var interval) ? interval : DefaultInterval;
}