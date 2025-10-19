using System;
using Xunit;
using MeteoMesh.Lite.LocalNode.State;
using MeteoMesh.Lite.LocalNode.Services;
using System.Linq;
using Grpc.Core;
using MeteoMesh.Lite.Proto;
using System.Threading.Tasks;

namespace LocalNode.Tests
{
    internal class TestServerCallContext : ServerCallContext
    {
        protected override Task WriteResponseHeadersAsync(Metadata responseHeaders) => Task.CompletedTask;
        protected override ContextPropagationToken CreatePropagationToken(ContextPropagationOptions options) => null!;
        protected override string MethodCore => "test";
        protected override string HostCore => "localhost";
        protected override string PeerCore => "peer";
        protected override DateTime DeadlineCore => DateTime.MaxValue;
        protected override Metadata RequestHeadersCore => new Metadata();
        protected override CancellationToken CancellationTokenCore => CancellationToken.None;
        protected override Metadata ResponseTrailersCore => new Metadata();
        protected override Status StatusCore { get; set; }
        protected override WriteOptions? WriteOptionsCore { get; set; }
        protected override AuthContext AuthContextCore => new AuthContext("", new System.Collections.Generic.Dictionary<string, System.Collections.Generic.List<string>>());

        public static ServerCallContext Create() => new TestServerCallContext();
    }

    public class LocalNodeDataServiceTests
    {
        [Fact]
        public async Task GetAggregatedData_returns_correct_counts_and_averages()
        {
            var store = new StationStore();
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

            store.AddMeasurement(new MeasurementEntry("s1", "temp", 10, now - 10000));
            store.AddMeasurement(new MeasurementEntry("s1", "temp", 20, now - 5000));
            store.AddMeasurement(new MeasurementEntry("s2", "humidity", 50, now - 2000));

            var svc = new LocalNodeDataService(store);
            var req = new AggregationRequest { Since = now - 20000 };

            var resp = await svc.GetAggregatedData(req, TestServerCallContext.Create());

            var temp = resp.Items.FirstOrDefault(i => i.Type == "temp");
            var hum = resp.Items.FirstOrDefault(i => i.Type == "humidity");

            Assert.NotNull(temp);
            Assert.Equal(2, temp.Count);
            Assert.Equal(15, temp.Average);

            Assert.NotNull(hum);
            Assert.Equal(1, hum.Count);
            Assert.Equal(50, hum.Average);
        }
    }
}
