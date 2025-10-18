var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject<Projects.central>("central");

builder.AddProject<Projects.localnode>("localnode");

builder.AddProject<Projects.station>("station");

builder.Build().Run();
