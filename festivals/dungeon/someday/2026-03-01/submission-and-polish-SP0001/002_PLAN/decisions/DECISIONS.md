# Key Decisions

## D-01: Dashboard is already complete

**Decision:** The dashboard codebase is fully implemented. All panel components, hooks, data connectors, and tests exist and import correctly. The earlier assessment that it was "stub only" was incorrect — the stubs in `src/components/` (lowercase folders) are unused placeholders. The real implementations live in `src/components/panels/`. No rebuild needed, just verify `next build` passes.

## D-02: 0G Serving contract address is known

**Decision:** Use the pre-deployed 0G inference serving contract at `0xa79F4c8311FF93C06b8CfB403690cc987c93F91E` on Galileo testnet (chain ID 16602). This is maintained by the 0G Foundation. No deployment needed.

**Risk:** The Go broker's ABI doesn't match the real contract. Must fix `broker.go` to use `getAllServices(offset, limit)` instead of `getServiceCount()`/`getService(uint256)`.

## D-03: Uniswap V3 SwapRouter02 on Base Sepolia

**Decision:** Use SwapRouter02 at `0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4`. The code already targets `exactInputSingle` in comments. Need to replace the stub function selector with real ABI encoding and add ERC-20 `approve` flow.

## D-04: ERC-8004 is pre-deployed on Base Sepolia

**Decision:** Use IdentityRegistry at `0x8004A818BFB912233c491871b3d84c89A494BD9e`. Need to fix `register.go` to use proper ABI encoding for the contract call.

## D-05: Parallel sequence execution

**Decision:** Dashboard verify, 0G unblock, and Base unblock can run in parallel (no dependencies between them). E2E cycle depends on all three completing. Demo video depends on E2E cycle.

## D-06: contracts/ project is out of scope

**Decision:** The Solidity contracts project is scaffold-only and was never built. It targets Hedera Track 2 which is a P2 stretch goal. Skip entirely for this festival.
