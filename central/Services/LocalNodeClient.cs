using Grpc.Net.Client;
using MeteoIpso.Proto;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace MeteoIpso
{
    public class LocalNodeClient
    {
        private readonly LocalNodeData.LocalNodeDataClient _client;

        public LocalNodeClient()
        {
            var ch = GrpcChannel.ForAddress("http://localhost:5001");
            _client = new LocalNodeData.LocalNodeDataClient(ch);
        }

        public async Task<IReadOnlyList<StationStatus>> GetStationsAsync()
        {
            var resp = await _client.GetStationsAsync(new QueryRequest());
            return resp.Items;
        }

        public async Task<IReadOnlyList<SensorAggregate>> GetAggregatedDataAsync(long sinceUnixMs)
        {
            var req = new AggregationRequest { Since = sinceUnixMs };
            var resp = await _client.GetAggregatedDataAsync(req);
            return resp.Items;
        }
    }
}