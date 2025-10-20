using System.Collections.Generic;
using System.Linq;

namespace MeteoIpso.LocalNode.State
{
    public record StationStatus(string StationId, string LastType, double LastValue, long LastTs, string State);
    public record MeasurementEntry(string StationId, string Type, double Value, long Timestamp);

    public class StationStore 
    {
        private readonly Dictionary<string, StationStatus> _map = new();
        private readonly List<MeasurementEntry> _measurements = new();
        private readonly object _lock = new();

        public void Upsert(StationStatus s) { lock(_lock) { _map[s.StationId] = s; } }
        public List<StationStatus> All() { lock(_lock) { return _map.Values.ToList(); } }
        public StationStatus? Get(string id) { lock(_lock) { return _map.TryGetValue(id, out var v) ? v : null; } }

        public void AddMeasurement(MeasurementEntry e) { lock(_lock) { _measurements.Add(e); /* keep buffer trimmed */ if (_measurements.Count > 10000) _measurements.RemoveRange(0, _measurements.Count - 8000); } }

        public List<MeasurementEntry> MeasurementsSince(long since) { lock(_lock) { return _measurements.Where(m => m.Timestamp >= since).ToList(); } }
    }
}