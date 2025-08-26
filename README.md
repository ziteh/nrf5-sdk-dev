# nRF5 SDK Development Environment

A Docker-based development environment for Nordic nRF5 SDK projects.

Available on x86-64 and Apple M-series Arm CPU.

## Getting Started

### Prerequisites

On the ***host***:

1. **nRF5 SDK**: [Download](https://www.nordicsemi.com/Products/Development-software/nRF5-SDK/Download#infotabs) and extract it to your preferred location, such as `~/Documents/sdk/nRF5_SDK_17.1.0_ddde560`.
2. **Environment Variable**: Set the `NRF5_SDK_PATH` environment variable to your SDK location. For example:
   ```bash
   export NRF5_SDK_PATH="~/Documents/sdk/nRF5_SDK_17.1.0_ddde560"
   ```
3. **Debugger**: Install either [J-Link](https://www.segger.com/downloads/jlink/) or [OpenOCD](https://openocd.org/).
4. **Configuration**: Check and modify the values in the [`.env`](./.env) file if necessary.

### GDB Server

Start the GDB server on the ***host***:

```bash
JLinkGDBServer -device nRF52840_xxAA -if SWD -speed 4000
```

### Development

In VS Code, press `Ctrl` + `Shift` + `P`, search for and select `Reopen in Container` to enter the dev container.

On the ***container***:

```bash
# Build firmware
make

# Clean the build folder
make clean

# Flash the firmware
make flash

# Erase the device
make erase

# Reset the device
make reset

# Display help
make help
```

Alternatively, you can use the VS Code Tasks from the menu bar: `Terminal` → `Run Task`.

### Debugging

In the ***container***, use the `Run and Debug` feature in VS Code. This will connect to the GDB server.

## Docker

### Build the Docker Image

On the ***host***:

```bash
docker build -t nrf5-sdk-dev ./.devcontainer
# or
podman build -t nrf5-sdk-dev ./.devcontainer
```

### Build Firmware on the Host

On the ***host***:

```bash
podman run --rm \
    -v "${PWD}:/workspace" \
    -v "${NRF5_SDK_PATH}:/opt/nrf5-sdk" \
    -w /workspace \
    nrf5-sdk-dev \
    bash -c "make clean && make"
```

## References

- [nRF5 SDK v17.1.0: Introduction](https://docs.nordicsemi.com/bundle/sdk_nrf5_v17.1.0/page/index.html)
- [J-Link GDB Server Commands](https://kb.segger.com/J-Link_GDB_Server#Supported_remote_(monitor)_commands)
- [GNU Arm Toolchain](https://developer.arm.com/downloads/-/gnu-rm)
- [Marus/cortex-debug: Visual Studio Code extension for Cortex-M Microcontrollers](https://github.com/Marus/cortex-debug)
- [NordicSemiconductor/nRF5-SDK-for-Mesh](https://github.com/NordicSemiconductor/nRF5-SDK-for-Mesh)
