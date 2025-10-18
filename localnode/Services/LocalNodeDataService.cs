using Grpc.Core;
using MeteoMesh.Lite.Proto;
using MeteoMesh.Lite.LocalNode.State;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MeteoMesh.Lite.LocalNode.Services
{
    public class LocalNodeDataService : LocalNodeData.LocalNodeDataBase
    {
        private readonly StationStore _store;

        public LocalNodeDataService(StationStore store)
        {
            _store = store;
        }

        public override Task<StationList> GetStations(QueryRequest req, ServerCallContext ctx)
        {
            var list = new StationList();
            list.Items.AddRange(_store.All().Select(s => new Proto.StationStatus
            {
                StationId = s.StationId,
                LastType = s.LastType,
                LastValue = s.LastValue,
                LastTs = s.LastTs,
                State = s.State
            }));
            return Task.FromResult(list);
        }
    }
}