using System.Collections.Generic;
using System.Linq;

namespace MeteoIpso.LocalNode.State
{
    // Einzelne Station mit einem Sensor
    public record StationStatus(string StationId, string LastType, double LastValue, long LastTs, string State);
    
    // Neue Struktur für Sensor-Status pro Station
    public record SensorStatus(string StationId, string SensorType, double Value, long Timestamp, string State);
    
    public record MeasurementEntry(string StationId, string Type, double Value, long Timestamp);

    public class StationStore 
    {
        // Alte Struktur für Kompatibilität (letzte Messung pro Station)
        private readonly Dictionary<string, StationStatus> _map = new();
        
        // Neue Struktur: Alle Sensoren pro Station
        private readonly Dictionary<string, Dictionary<string, SensorStatus>> _sensorMap = new();
        
        private readonly List<MeasurementEntry> _measurements = new();
        private readonly object _lock = new();

        public void Upsert(StationStatus s) 
        { 
            lock(_lock) 
            { 
                _map[s.StationId] = s;
                
                // Speichere auch pro Sensor
                if (!_sensorMap.ContainsKey(s.StationId))
                {
                    _sensorMap[s.StationId] = new Dictionary<string, SensorStatus>();
                }
                
                _sensorMap[s.StationId][s.LastType] = new SensorStatus(
                    s.StationId,
                    s.LastType,
                    s.LastValue,
                    s.LastTs,
                    s.State
                );
            } 
        }
        
        // Alte Methode: Gibt eine Zeile pro Station zurück (letzte Messung)
        public List<StationStatus> All() { lock(_lock) { return _map.Values.ToList(); } }
        
        // Neue Methode: Gibt ALLE Sensoren aller Stationen zurück
        public List<SensorStatus> AllSensors() 
        { 
            lock(_lock) 
            { 
                return _sensorMap.Values
                    .SelectMany(sensors => sensors.Values)
                    .OrderBy(s => s.StationId)
                    .ThenBy(s => s.SensorType)
                    .ToList(); 
            } 
        }
        
        // Gibt alle Sensoren einer bestimmten Station zurück
        public List<SensorStatus> GetStationSensors(string stationId)
        {
            lock(_lock)
            {
                if (_sensorMap.TryGetValue(stationId, out var sensors))
                {
                    return sensors.Values.ToList();
                }
                return new List<SensorStatus>();
            }
        }
        
        public StationStatus? Get(string id) { lock(_lock) { return _map.TryGetValue(id, out var v) ? v : null; } }

        public void AddMeasurement(MeasurementEntry e) { lock(_lock) { _measurements.Add(e); /* keep buffer trimmed */ if (_measurements.Count > 10000) _measurements.RemoveRange(0, _measurements.Count - 8000); } }

        public List<MeasurementEntry> MeasurementsSince(long since) { lock(_lock) { return _measurements.Where(m => m.Timestamp >= since).ToList(); } }
    }
}