using System;
using Xunit;

public class MeasurementSchedulerTests
{
    private class TestClock : IClock
    {
        private DateTimeOffset _now = DateTimeOffset.UtcNow;
        public DateTimeOffset UtcNow => _now;
        
        public Task Delay(TimeSpan delay, CancellationToken ct = default)
        {
            _now = _now.Add(delay);
            return Task.CompletedTask;
        }
    }

    [Fact]
    public async Task Humidity_measurement_skipped_when_raining()
    {
        var clock = new TestClock();
        var coordinator = new SensorCoordinator();
        var scheduler = new MeasurementScheduler(clock, coordinator);

        // Simulate rain
        coordinator.ObserveLidar(1.5, clock.UtcNow.ToUnixTimeMilliseconds());

        var shouldMeasure = await scheduler.WaitForNextMeasurement("humidity", CancellationToken.None);
        Assert.False(shouldMeasure, "Humidity measurement should be skipped when raining");
    }

    [Fact]
    public async Task Temperature_interval_halved_on_high_pressure()
    {
        var clock = new TestClock();
        var coordinator = new SensorCoordinator();
        var scheduler = new MeasurementScheduler(clock, coordinator);
        var start = clock.UtcNow;

        coordinator.UpdatePressure(960); // > 950 hPa
        await scheduler.WaitForNextMeasurement("temperature", CancellationToken.None);

        var elapsed = clock.UtcNow - start;
        Assert.Equal(TimeSpan.FromMinutes(7.5), elapsed); // 15min / 2
    }

    [Fact]
    public void Base_intervals_match_requirements()
    {
        Assert.Equal(TimeSpan.FromMinutes(15), MeasurementScheduler.GetBaseInterval("temperature"));
        Assert.Equal(TimeSpan.FromMinutes(15), MeasurementScheduler.GetBaseInterval("humidity"));
        Assert.Equal(TimeSpan.FromMinutes(15), MeasurementScheduler.GetBaseInterval("pressure"));
        Assert.Equal(TimeSpan.FromMinutes(5), MeasurementScheduler.GetBaseInterval("lidar"));
    }
}