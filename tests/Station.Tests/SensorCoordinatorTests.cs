using System;
using Xunit;

public class SensorCoordinatorTests
{
    [Fact]
    public void Lidar_sets_isRaining_and_clears_after_timeout()
    {
        var c = new SensorCoordinator();
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        c.ObserveLidar(0, now);
        Assert.False(c.IsRaining);

        c.ObserveLidar(1.2, now + 10);
        Assert.True(c.IsRaining);

        // after 6 seconds without rain it should clear
        c.ObserveLidar(0, now + 6100);
        Assert.False(c.IsRaining);
    }

    [Fact]
    public void Humidity_should_be_skipped_when_raining()
    {
        var c = new SensorCoordinator();
        var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        c.ObserveLidar(1.0, now);
        Assert.True(c.ShouldSkipHumidity());

        c.ObserveLidar(0, now + 6000);
        Assert.False(c.ShouldSkipHumidity());
    }

    [Fact]
    public void Temperature_interval_halves_when_pressure_high()
    {
        var c = new SensorCoordinator();
        var baseInterval = TimeSpan.FromSeconds(3);

        c.UpdatePressure(940);
        var i1 = c.GetTemperatureInterval(baseInterval);
        Assert.Equal(baseInterval, i1);

        c.UpdatePressure(960);
        var i2 = c.GetTemperatureInterval(baseInterval);
        Assert.Equal(TimeSpan.FromSeconds(1.5), i2);
    }
}
