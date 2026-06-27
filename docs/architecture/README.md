# Ridoo Architecture

## System Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Customer   │     │   Driver    │     │    Admin    │
│  Flutter    │     │   Flutter   │     │  Filament   │
└──────┬──────┘     └──────┬──────┘     └──────┬──────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                    ┌──────▼──────┐
                    │   Laravel   │
                    │     API     │
                    └──────┬──────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
        ┌─────▼─────┐ ┌───▼───┐ ┌─────▼─────┐
        │   MySQL   │ │ Redis │ │  Reverb   │
        └───────────┘ └───────┘ └───────────┘
```

## Key Flows

1. **Booking** — Customer selects locations → API finds nearby drivers → WebSocket notifies drivers
2. **Tracking** — Driver GPS → API → Redis → WebSocket → Customer map
3. **Payment** — Ride complete → fare calculation → payment gateway / wallet → invoice

See `docs/setup_guide/` and `docs/deployment_guide/` for operational details.
