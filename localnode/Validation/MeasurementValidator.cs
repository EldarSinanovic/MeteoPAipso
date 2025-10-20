using System;
using System.Collections.Generic;

namespace MeteoMesh.Lite.LocalNode.Validation
{
    public record ValidationResult(bool IsValid, string? ErrorMessage = null);

    public interface IMeasurementValidator
    {
        ValidationResult Validate(MeteoMesh.Lite.Proto.Measurement measurement);
    }

    public class MeasurementValidator : IMeasurementValidator
    {
        private static readonly Dictionary<string, (double Min, double Max)> ValidRanges = new()
        {
            ["temperature"] = (-50.0, 60.0),      // -50°C to +60°C
            ["humidity"] = (0.0, 100.0),          // 0-100%
            ["pressure"] = (800.0, 1100.0),       // 800-1100 hPa (typical sea level range)
            ["lidar"] = (0.0, 50.0)              // 0-50mm rain (reasonable max)
        };

        private static readonly TimeSpan MaxAge = TimeSpan.FromMinutes(30); // measurements shouldn't be more than 30min old

        public ValidationResult Validate(Proto.Measurement m)
        {
            // Check required fields
            if (string.IsNullOrWhiteSpace(m.StationId))
                return new ValidationResult(false, "StationId is required");
            
            if (string.IsNullOrWhiteSpace(m.Type))
                return new ValidationResult(false, "Type is required");

            // Check timestamp (not from future, not too old)
            var now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
            if (m.Timestamp > now)
                return new ValidationResult(false, "Measurement timestamp is in the future");

            var age = TimeSpan.FromMilliseconds(now - m.Timestamp);
            if (age > MaxAge)
                return new ValidationResult(false, $"Measurement is too old ({age.TotalMinutes:F1} minutes)");

            // Check value range if defined for this sensor type
            if (ValidRanges.TryGetValue(m.Type, out var range))
            {
                if (m.Value < range.Min || m.Value > range.Max)
                    return new ValidationResult(false, $"Value {m.Value} is outside valid range [{range.Min}, {range.Max}] for {m.Type}");
            }

            return new ValidationResult(true);
        }
    }
}