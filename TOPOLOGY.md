<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->
<!-- SPDX-FileCopyrightText: 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk> -->

# natsci-studio — Topology

## System Overview

Monorepo of natural-sciences libraries plus a Haskell-backed TUI console
(NatTrans Console). Contractile-first: every substantive change is gated
by the verb tridents under `.machine_readable/contractiles/`.

## Component Overview

| Component           | Language       | Purpose                                             |
|---------------------|----------------|-----------------------------------------------------|
| NatTrans Console    | Haskell        | TUI for minting / verifying / observing libraries.  |
| libs/*              | mixed          | Natural-sciences libraries (one per topic).         |
| contractile tridents| A2ML + Nickel  | Normative obligations (intend/trust/must/bust/adjust/dust). |
| 6a2/*               | A2ML           | Descriptive state (what IS — opposed to ought).     |

## Integration Points

- **Upstream**: `standards/` provides the canonical trident machinery.
- **Downstream (future)**: educational / research consumers.

## Deployment

Not yet containerised. Scaffold stage.
