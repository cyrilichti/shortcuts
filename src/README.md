# Source structure

The shared CLI is split by responsibility:

- `../bin/shortcuts` defines the `argc` command handlers. Each handler receives
  parsed arguments and delegates to a controller through `dispatch`.
- `dispatcher.sh` is the technical execution boundary. It runs a controller,
  logs the outcome, and forwards the response and exit status.
- `controllers/` contains action orchestration. Controllers may depend on one
  or more services as business capabilities are implemented.

Business-specific decisions belong in controllers or their services, not in
the command handlers or dispatcher.
