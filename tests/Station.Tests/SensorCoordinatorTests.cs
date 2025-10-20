using System;
using Xunit;

namespace MeteoIpso.Station.Tests
{
    public class SensorCoordinatorTests
    {
        [Fact]
        public void IsRaining_returns_false_initially()
        {
            var c = new SensorCoordinator();
            Assert.False(c.IsRaining);
        }

        [Fact]
        public void IsRaining_returns_true_when_rain_detected()
        {
            var c = new SensorCoordinator();
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            
            c.ObserveLidar(1.2, now);
            Assert.True(c.IsRaining);
        }

        [Fact]
        public void IsRaining_clears_after_timeout()
        {
            var c = new SensorCoordinator();
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            
            c.ObserveLidar(1.2, now);
            Assert.True(c.IsRaining);

            c.ObserveLidar(0, now + 6000); // 6 seconds without rain
            Assert.False(c.IsRaining);
        }

        [Fact]
        public void ShouldSkipHumidity_follows_rain_state()
        {
            var c = new SensorCoordinator();
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            
            Assert.False(c.ShouldSkipHumidity());
            
            c.ObserveLidar(1.0, now);
            Assert.True(c.ShouldSkipHumidity());
            
            c.ObserveLidar(0, now + 6000);
            Assert.False(c.ShouldSkipHumidity());
        }

        [Fact]
        public void Temperature_interval_halved_when_pressure_high()
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
}
