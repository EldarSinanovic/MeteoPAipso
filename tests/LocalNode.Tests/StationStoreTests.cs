using System;
using Xunit;
using MeteoIpso.LocalNode.State;
using System.Linq;

namespace LocalNode.Tests
{
    public class StationStoreTests
    {
        [Fact]
        public void MeasurementsSince_returns_only_recent()
        {
            var store = new StationStore();
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

            store.AddMeasurement(new MeasurementEntry("s1", "temp", 10, now - 5000));
            store.AddMeasurement(new MeasurementEntry("s1", "temp", 12, now - 1000));
            store.AddMeasurement(new MeasurementEntry("s2", "humidity", 50, now - 200));

            var list = store.MeasurementsSince(now - 2000);
            Assert.Equal(2, list.Count);
            Assert.DoesNotContain(list, m => m.Timestamp < now - 2000);
        }
    }
}
