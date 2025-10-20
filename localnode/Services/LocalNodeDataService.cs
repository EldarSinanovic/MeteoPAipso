using Grpc.Core;
using MeteoIpso.Proto;
using MeteoIpso.LocalNode.State;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MeteoIpso.LocalNode.Services
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

        public override Task<AggregatedData> GetAggregatedData(AggregationRequest req, ServerCallContext ctx)
        {
            var since = req.Since;
            if (since == 0)
            {
                // default: last 1 hour
                since = DateTimeOffset.UtcNow.AddHours(-1).ToUnixTimeMilliseconds();
            }

            var measurements = _store.MeasurementsSince(since);
            var groups = measurements.GroupBy(m => m.Type);

            var resp = new AggregatedData();

            foreach (var g in groups)
            {
                var count = g.LongCount();
                var avg = g.Average(x => x.Value);
                resp.Items.Add(new SensorAggregate { Type = g.Key, Count = count, Average = avg });
            }

            return Task.FromResult(resp);
        }
    }
}