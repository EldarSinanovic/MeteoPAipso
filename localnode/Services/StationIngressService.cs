using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Grpc.Core;
using MeteoMesh.Lite.Proto;
using MeteoMesh.Lite.LocalNode.State;

namespace MeteoMesh.Lite.LocalNode.Services
{
    public class StationIngressService : StationIngress.StationIngressBase
    {
        private readonly StationStore _store;
        
        public StationIngressService(StationStore store) => _store = store;

        public override Task<SubmitReply> SubmitMeasurement(Measurement m, ServerCallContext ctx)
        {
            var state = "Active";
            if (m.Type == "rain" && m.Value > 0) state = "Suspended";

            _store.Upsert(new State.StationStatus(
                m.StationId, // StationId
                m.Type,     // LastType
                m.Value,    // LastValue
                m.Timestamp,// LastTs
                state      // State
            ));

            // Add measurement to store for aggregation
            _store.AddMeasurement(new MeasurementEntry(m.StationId, m.Type, m.Value, m.Timestamp));
            
            Console.WriteLine($"[Ingress] {m.StationId} {m.Type}={m.Value} state={state}");
            return Task.FromResult(new SubmitReply { Ok = true });
        }
    }
}