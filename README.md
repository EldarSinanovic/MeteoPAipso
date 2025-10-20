# MeteoIpso

## Overview

MeteoMesh Lite is a lightweight meteorological data collection and visualization system. It consists of three main components: a central Blazor Server application, a LocalNode console application, and a Station console application. The system uses gRPC for communication between components and stores data in memory without the need for a database.

## Components

1. **Central**: A Blazor Server application that provides a web interface to display the status and measurements from various stations.
2. **LocalNode**: A console application that acts as a gRPC server, receiving measurements from stations and providing status information to the central application.
3. **Station**: A console application that simulates a weather station, periodically sending measurement data to the LocalNode.

## Getting Started

### Prerequisites

- .NET SDK (version 8 or 9)
- Visual Studio Code with the following extensions:
  - C# Dev Kit or C#
  - GitHub Copilot
  - gRPC (optional)

### Setup

1. Clone the repository or download the project files.
2. Open a terminal and navigate to the project directory.
3. Restore the project dependencies:
   ```bash
   dotnet restore
   ```

### Running the Application

1. Start the LocalNode service:
   ```bash
   dotnet run --project localnode
   ```

2. Start one or more Station instances:
   ```bash
   dotnet run --project station -- station-001
   dotnet run --project station -- station-002
   ```

3. Start the Central Blazor application:
   ```bash
   dotnet run --project central
   ```

4. Open your web browser and navigate to the URL provided by the Blazor development server. You should see a table displaying the status of all active stations.

## Features

- Real-time data collection from multiple stations.
- Simple and intuitive web interface for monitoring station statuses.
- In-memory data storage for quick access and low overhead.
- Easy to extend with additional features and services.

## Future Enhancements

- Implement additional monitoring rules and alerts.
- Add command handling for station control.
- Containerize the application using Docker for easier deployment.
- Implement logging and monitoring features for better observability.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
