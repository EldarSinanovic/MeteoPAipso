using Grpc.Core;
using MeteoMesh.Lite.Proto;
using System.Threading.Tasks;

public class StationControlService : StationControl.StationControlBase {
    public override Task<CommandReply> SendCommand(CommandRequest request, ServerCallContext context) {
        // Stub implementation for future command handling
        return Task.FromResult(new CommandReply { Ok = true });
    }
}