using Grpc.Net.Client;
using MeteoMesh.Lite.Proto;
using System.Threading.Tasks;
using System.Collections.Generic;

namespace MeteoMesh.Lite
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
    }
}