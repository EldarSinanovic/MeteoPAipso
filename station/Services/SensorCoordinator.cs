using System;

// Lightweight coordinator to encapsulate synchronization rules for sensors.
// No namespace to match existing StationWorker placement.
public class SensorCoordinator
{
    private bool _isRaining = false;
    private long _lastRainTimestamp = 0; // unix ms
    private double _currentPressure = 1013.25;

    // Call when lidar reports a value at given timestamp (unix ms)
    public void ObserveLidar(double rainValue, long timestampMs)
    {
        if (rainValue > 0)
        {
            _isRaining = true;
            _lastRainTimestamp = timestampMs;
        }
        else
        {
            if (_isRaining && timestampMs - _lastRainTimestamp > 5000)
            {
                _isRaining = false;
            }
        }
    }

    public bool IsRaining => _isRaining;

    // Humidity measurement should be skipped when raining
    public bool ShouldSkipHumidity() => _isRaining;

    public void UpdatePressure(double pressure)
    {
        _currentPressure = pressure;
    }

    // Returns adjusted interval based on current pressure
    public TimeSpan GetTemperatureInterval(TimeSpan baseInterval)
    {
        return (_currentPressure > 950) ? TimeSpan.FromSeconds(baseInterval.TotalSeconds / 2.0) : baseInterval;
    }

    // For testing: expose current pressure
    public double CurrentPressure => _currentPressure;
}
