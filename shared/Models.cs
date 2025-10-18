using System;

namespace MeteoMesh.Lite.Shared
{
    public record StationStatus(string StationId, string LastType, double LastValue, long LastTs, string State);
}