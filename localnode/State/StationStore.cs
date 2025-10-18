using System.Collections.Generic;

namespace MeteoMesh.Lite.LocalNode.State
{
    public record StationStatus(string StationId, string LastType, double LastValue, long LastTs, string State);

    public class StationStore 
    {
        private readonly Dictionary<string, StationStatus> _map = new();
        private readonly object _lock = new();

        public void Upsert(StationStatus s) { lock(_lock) { _map[s.StationId] = s; } }
        public List<StationStatus> All() { lock(_lock) { return _map.Values.ToList(); } }
        public StationStatus? Get(string id) { lock(_lock) { return _map.TryGetValue(id, out var v) ? v : null; } }
    }
}