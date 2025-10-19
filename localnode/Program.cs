using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using MeteoMesh.Lite.LocalNode.Services;
using MeteoMesh.Lite.LocalNode.State;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Serilog;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using Prometheus;

namespace MeteoMesh.Lite.LocalNode
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);
            builder.Host.UseSerilog((ctx, lc) => lc.WriteTo.Console());

            // Configure Kestrel to allow HTTP/2 on the plaintext endpoint
            builder.WebHost.ConfigureKestrel(options =>
            {
                options.ListenAnyIP(5001, listenOptions =>
                {
                    // Allow HTTP/2 without TLS for local development
                    listenOptions.Protocols = HttpProtocols.Http2;
                });
            });

            builder.Services.AddSingleton<StationStore>();
            builder.Services.AddGrpc();

            var app = builder.Build();

            // Map prometheus metrics
            app.UseRouting();
            app.UseHttpMetrics();
            app.MapMetrics();

            app.MapGrpcService<StationIngressService>();
            app.MapGrpcService<LocalNodeDataService>();
            app.MapGet("/", () => "LocalNode up");

            app.Run();
        }
    }
}