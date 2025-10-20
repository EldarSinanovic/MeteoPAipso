using Grpc.Core;
using MeteoIpso.Proto;
using System.Threading.Tasks;

public class StationControlService : StationControl.StationControlBase
{
    public override Task<CommandReply> SendCommand(CommandRequest request, ServerCallContext context)
    {
        // Placeholder for station control commands
        return Task.FromResult(new CommandReply { Ok = true });
    }
}