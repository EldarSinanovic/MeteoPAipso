using System;
using Xunit;
using MeteoIpso.LocalNode.Validation;

namespace LocalNode.Tests
{
    public class MeasurementValidatorTests
    {
        private readonly IMeasurementValidator _validator = new MeasurementValidator();
        private readonly string _validStationId = "test-001";
        private readonly long _validTimestamp = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

        [Theory]
        [InlineData("temperature", -30.0, true)]  // valid cold
        [InlineData("temperature", 40.0, true)]   // valid hot
        [InlineData("temperature", -60.0, false)] // too cold
        [InlineData("temperature", 70.0, false)]  // too hot
        [InlineData("humidity", 50.0, true)]      // valid humidity
        [InlineData("humidity", 120.0, false)]    // impossible humidity
        [InlineData("pressure", 1013.25, true)]   // valid pressure
        [InlineData("pressure", 700.0, false)]    // too low pressure
        [InlineData("lidar", 5.0, true)]         // valid rain
        [InlineData("lidar", 60.0, false)]       // unrealistic rain
        public void Value_ranges_are_validated(string type, double value, bool shouldBeValid)
        {
            var m = new MeteoIpso.Proto.Measurement
            {
                StationId = _validStationId,
                Type = type,
                Value = value,
                Timestamp = _validTimestamp
            };

            var result = _validator.Validate(m);
            Assert.Equal(shouldBeValid, result.IsValid);
        }

        [Fact]
        public void Future_timestamp_is_rejected()
        {
            var m = new MeteoIpso.Proto.Measurement
            {
                StationId = _validStationId,
                Type = "temperature",
                Value = 20.0,
                Timestamp = DateTimeOffset.UtcNow.AddMinutes(5).ToUnixTimeMilliseconds()
            };

            var result = _validator.Validate(m);
            Assert.False(result.IsValid);
            Assert.Contains("future", result.ErrorMessage?.ToLower());
        }

        [Fact]
        public void Old_measurements_are_rejected()
        {
            var m = new MeteoIpso.Proto.Measurement
            {
                StationId = _validStationId,
                Type = "temperature",
                Value = 20.0,
                Timestamp = DateTimeOffset.UtcNow.AddMinutes(-31).ToUnixTimeMilliseconds()
            };

            var result = _validator.Validate(m);
            Assert.False(result.IsValid);
            Assert.Contains("old", result.ErrorMessage?.ToLower());
        }

        [Theory]
        [InlineData(null)]
        [InlineData("")]
        [InlineData(" ")]
        public void StationId_is_required(string? stationId)
        {
            var m = new MeteoIpso.Proto.Measurement
            {
                StationId = stationId,
                Type = "temperature",
                Value = 20.0,
                Timestamp = _validTimestamp
            };

            var result = _validator.Validate(m);
            Assert.False(result.IsValid);
            Assert.Contains("StationId", result.ErrorMessage);
        }
    }
}