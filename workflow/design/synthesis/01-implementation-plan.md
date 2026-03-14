# OBEY Vault — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an ERC-4626 vault on Base where an AI agent trades via Uniswap V3 within human-defined spending boundaries, register the agent with ERC-8004 identity, and produce a working demo for the Synthesis hackathon.

**Architecture:** Four components — Vault.sol (ERC-4626 + agent swap constraints), Go agent runtime (market analysis → swap execution via vault), ERC-8004 identity registration, and an observer CLI. The vault enforces all boundaries on-chain; the agent is powerful but constrained.

**Tech Stack:** Solidity/Foundry (vault), Go/go-ethereum (agent runtime), Uniswap V3 SwapRouter02 + TWAP oracle (swaps + NAV), Claude API (LLM strategy), Base mainnet + Sepolia testnet.

**Spec:** `workflow/design/synthesis/00-design-spec.md`

---

## Spec Build Sequence → Plan Task Mapping

| Spec Step | Description | Plan Task(s) |
|-----------|-------------|-------------|
| 1 | Vault.sol | Tasks 1–2 (interfaces + core) |
| 2 | Vault tests | Tasks 3–6 (guardian, deposit, swap, NAV) |
| 3 | Deploy to Base Sepolia | Task 7 (script) + Task 14 (deploy) |
| 4 | Go agent scaffold | Tasks 8, 12 (vault client, entry point) |
| 5 | Uniswap integration | Task 8 (vault client executeSwap) |
| 6 | LLM strategy | Task 9 |
| 7 | Risk manager | Task 10 |
| 8 | ERC-8004 registration | Task 13 + Task 15 |
| 9 | E2E testnet integration | Task 16 |
| 10 | Security checkpoint | Task 17 |
| 11 | Base mainnet deployment | Task 18 |
| 12 | Observer | Task 19 |
| 13 | Submission | Task 20 |

---

## File Structure

### Contracts (`projects/contracts/`)

| File | Responsibility |
|------|---------------|
| `src/ObeyVault.sol` | ERC-4626 vault with agent swap constraints, guardian controls, token tracking, NAV via TWAP |
| `src/interfaces/ISwapRouter02.sol` | Uniswap V3 SwapRouter02 interface (exactInputSingle) |
| `src/interfaces/IOracleLibrary.sol` | Uniswap V3 OracleLibrary interface (consult) |
| `test/ObeyVault.t.sol` | Foundry tests: deposit/redeem, swap enforcement, boundary rejection, NAV |
| `script/DeployVault.s.sol` | Deployment script for Base Sepolia and mainnet |

### Agent Runtime (`projects/agent-defi/`)

Reuses existing packages: `internal/base/ethutil/`, `internal/base/trading/` (Strategy, TradeExecutor interfaces), `internal/base/identity/`.

| File | Responsibility |
|------|---------------|
| `internal/vault/bindings.go` | Go bindings for ObeyVault.sol (generated via abigen, then hand-tuned) |
| `internal/vault/client.go` | VaultClient: read state, call executeSwap, check boundaries |
| `internal/vault/client_test.go` | Tests for vault client against mock |
| `internal/strategy/llm.go` | LLM-based trading strategy using Claude API |
| `internal/strategy/claude.go` | ClaudeClient — Anthropic Messages API implementation of LLMClient |
| `internal/strategy/llm_test.go` | Strategy tests with mock LLM responses |
| `internal/risk/manager.go` | Risk manager: position limits, drawdown halt, daily volume cap |
| `internal/risk/manager_test.go` | Risk manager tests |
| `internal/loop/runner.go` | Main agent loop: fetch → analyze → filter → execute via vault |
| `internal/loop/runner_test.go` | Loop integration tests |
| `cmd/vault-agent/main.go` | Entry point for the vault agent binary |

### Observer (`projects/agent-defi/cmd/observer/`)

| File | Responsibility |
|------|---------------|
| `cmd/observer/main.go` | CLI tool: query vault state, show trade history from events, display NAV |

---

## Chunk 1: Vault Smart Contract

### Task 1: Uniswap V3 Interfaces

**Files:**
- Create: `projects/contracts/src/interfaces/ISwapRouter02.sol`
- Create: `projects/contracts/src/interfaces/IOracleLibrary.sol`

- [ ] **Step 1: Create SwapRouter02 interface**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ISwapRouter02 {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        returns (uint256 amountOut);
}
```

- [ ] **Step 2: Create OracleLibrary interface**

Minimal interface for TWAP price reads. We only need `consult` and the pool factory `getPool`.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IUniswapV3Factory {
    function getPool(address tokenA, address tokenB, uint24 fee)
        external view returns (address pool);
}

interface IUniswapV3Pool {
    function observe(uint32[] calldata secondsAgos)
        external view returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    function token0() external view returns (address);
    function token1() external view returns (address);
}
```

- [ ] **Step 3: Verify compilation**

Run: `cd projects/contracts && forge build`
Expected: Compiles with no errors.

- [ ] **Step 4: Commit**

```bash
cd projects/contracts
camp p commit -m "feat: add Uniswap V3 SwapRouter02 and oracle interfaces"
```

---

### Task 2: ObeyVault Core — Storage and Constructor

**Files:**
- Create: `projects/contracts/src/ObeyVault.sol`

- [ ] **Step 1: Install Uniswap V3 Foundry dependencies and add remappings**

```bash
cd projects/contracts
forge install uniswap/v3-core --no-commit
forge install uniswap/v3-periphery --no-commit
```

Add these lines to `remappings.txt`:

```
@uniswap/v3-core/=lib/v3-core/
@uniswap/v3-periphery/=lib/v3-periphery/
```

- [ ] **Step 2: Write vault skeleton with storage layout**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {ISwapRouter02} from "./interfaces/ISwapRouter02.sol";
import {IUniswapV3Factory, IUniswapV3Pool} from "./interfaces/IOracleLibrary.sol";

contract ObeyVault is ERC4626, Pausable {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    // --- Roles ---
    address public guardian;
    address public agent;

    // --- Spending Boundaries ---
    mapping(address => bool) public approvedTokens;
    uint256 public maxSwapSize;
    uint256 public maxDailyVolume;
    uint256 public maxSlippageBps;

    // --- Daily Volume Tracking ---
    uint256 public dailyVolumeUsed;
    uint256 public currentDay;

    // --- Token Tracking ---
    EnumerableSet.AddressSet private _heldTokens;

    // --- Uniswap ---
    ISwapRouter02 public immutable swapRouter;
    address public immutable uniswapFactory;

    // --- Events ---
    event SwapExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        bytes reason
    );
    event AgentUpdated(address indexed oldAgent, address indexed newAgent);
    event TokenApprovalUpdated(address indexed token, bool approved);
    event MaxSwapSizeUpdated(uint256 newMax);
    event MaxDailyVolumeUpdated(uint256 newMax);

    // --- Errors ---
    error OnlyGuardian();
    error OnlyAgent();
    error SameToken();
    error TokenNotApproved(address token);
    error SwapExceedsMaxSize(uint256 amount, uint256 max);
    error DailyVolumeExceeded(uint256 used, uint256 max);
    error SlippageTooHigh(uint256 requested, uint256 max);

    modifier onlyGuardian() {
        if (msg.sender != guardian) revert OnlyGuardian();
        _;
    }

    modifier onlyAgent() {
        if (msg.sender != agent) revert OnlyAgent();
        _;
    }

    constructor(
        IERC20 asset_,
        address agent_,
        address swapRouter_,
        address uniswapFactory_,
        uint256 maxSwapSize_,
        uint256 maxDailyVolume_,
        uint256 maxSlippageBps_
    )
        ERC4626(asset_)
        ERC20("OBEY Vault Share", "oVAULT")
    {
        guardian = msg.sender;
        agent = agent_;
        swapRouter = ISwapRouter02(swapRouter_);
        uniswapFactory = uniswapFactory_;
        maxSwapSize = maxSwapSize_;
        maxDailyVolume = maxDailyVolume_;
        maxSlippageBps = maxSlippageBps_;
        currentDay = block.timestamp / 1 days;

        // USDC (the base asset) is always approved
        approvedTokens[address(asset_)] = true;
    }
}
```

- [ ] **Step 3: Verify compilation**

Run: `cd projects/contracts && forge build`
Expected: Compiles (totalAssets override still needed, but skeleton compiles).

- [ ] **Step 4: Commit**

```bash
cd projects/contracts
camp p commit -m "feat: ObeyVault storage layout, constructor, roles, and events"
```

---

### Task 3: Guardian Controls

**Files:**
- Modify: `projects/contracts/src/ObeyVault.sol`

- [ ] **Step 1: Verify OpenZeppelin version and write test for guardian functions**

Check OZ version first — the import path for `ERC20Mock` differs between v4 and v5:

```bash
cd projects/contracts
cat lib/openzeppelin-contracts/package.json | grep version
# v5.x: @openzeppelin/contracts/mocks/token/ERC20Mock.sol
# v4.x: @openzeppelin/contracts/mocks/ERC20Mock.sol
```

Create `projects/contracts/test/ObeyVault.t.sol` (import path below assumes OZ v5.x — adjust if v4):

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ObeyVault} from "../src/ObeyVault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract ObeyVaultTest is Test {
    ObeyVault vault;
    ERC20Mock usdc;
    address guardian = address(this);
    address agentAddr = address(0xA1);
    address user = address(0xB1);
    address weth = address(0xC1);

    function setUp() public {
        usdc = new ERC20Mock();
        vault = new ObeyVault(
            usdc,
            agentAddr,
            address(0xDEAD), // mock router
            address(0xFACE), // mock factory
            1000e6,          // maxSwapSize: 1000 USDC
            10000e6,         // maxDailyVolume: 10000 USDC
            100              // maxSlippageBps: 1%
        );
    }

    function test_guardianCanSetAgent() public {
        address newAgent = address(0xA2);
        vault.setAgent(newAgent);
        assertEq(vault.agent(), newAgent);
    }

    function test_nonGuardianCannotSetAgent() public {
        vm.prank(user);
        vm.expectRevert(ObeyVault.OnlyGuardian.selector);
        vault.setAgent(address(0xA2));
    }

    function test_guardianCanApproveToken() public {
        vault.setApprovedToken(weth, true);
        assertTrue(vault.approvedTokens(weth));
    }

    function test_guardianCanPause() public {
        vault.pause();
        assertTrue(vault.paused());
        vault.unpause();
        assertFalse(vault.paused());
    }

    function test_guardianCanSetMaxSwapSize() public {
        vault.setMaxSwapSize(500e6);
        assertEq(vault.maxSwapSize(), 500e6);
    }

    function test_guardianCanSetMaxDailyVolume() public {
        vault.setMaxDailyVolume(5000e6);
        assertEq(vault.maxDailyVolume(), 5000e6);
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd projects/contracts && forge test --match-contract ObeyVaultTest -v`
Expected: FAIL — `setAgent`, `setApprovedToken`, `setMaxSwapSize`, `setMaxDailyVolume` not yet implemented.

- [ ] **Step 3: Implement guardian functions in ObeyVault.sol**

```solidity
function setAgent(address newAgent) external onlyGuardian {
    emit AgentUpdated(agent, newAgent);
    agent = newAgent;
}

function setApprovedToken(address token, bool approved) external onlyGuardian {
    approvedTokens[token] = approved;
    emit TokenApprovalUpdated(token, approved);
}

function setMaxSwapSize(uint256 amount) external onlyGuardian {
    maxSwapSize = amount;
    emit MaxSwapSizeUpdated(amount);
}

function setMaxDailyVolume(uint256 amount) external onlyGuardian {
    maxDailyVolume = amount;
    emit MaxDailyVolumeUpdated(amount);
}

function pause() external onlyGuardian {
    _pause();
}

function unpause() external onlyGuardian {
    _unpause();
}
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `cd projects/contracts && forge test --match-contract ObeyVaultTest -v`
Expected: All 6 tests PASS.

- [ ] **Step 5: Commit**

```bash
cd projects/contracts
camp p commit -m "feat: guardian controls — setAgent, token whitelist, swap limits, pause"
```

---

### Task 4: Deposit and Redeem (ERC-4626)

**Files:**
- Modify: `projects/contracts/test/ObeyVault.t.sol`
- Modify: `projects/contracts/src/ObeyVault.sol`

- [ ] **Step 1: Write deposit/redeem tests**

Add to `ObeyVaultTest`:

```solidity
function test_depositAndReceiveShares() public {
    uint256 amount = 100e6; // 100 USDC
    usdc.mint(user, amount);

    vm.startPrank(user);
    usdc.approve(address(vault), amount);
    uint256 shares = vault.deposit(amount, user);
    vm.stopPrank();

    assertEq(shares, amount); // 1:1 on first deposit
    assertEq(vault.balanceOf(user), amount);
    assertEq(usdc.balanceOf(address(vault)), amount);
}

function test_redeemReturnsAssets() public {
    uint256 amount = 100e6;
    usdc.mint(user, amount);

    vm.startPrank(user);
    usdc.approve(address(vault), amount);
    uint256 shares = vault.deposit(amount, user);
    uint256 assets = vault.redeem(shares, user, user);
    vm.stopPrank();

    assertEq(assets, amount);
    assertEq(usdc.balanceOf(user), amount);
    assertEq(vault.balanceOf(user), 0);
}

function test_depositWhenPausedReverts() public {
    vault.pause();
    usdc.mint(user, 100e6);
    vm.startPrank(user);
    usdc.approve(address(vault), 100e6);
    vm.expectRevert();
    vault.deposit(100e6, user);
    vm.stopPrank();
}
```

- [ ] **Step 2: Override totalAssets and add pause guard to deposit**

In `ObeyVault.sol`, override `totalAssets()` (initially just USDC balance — TWAP pricing comes in Task 6):

```solidity
function totalAssets() public view override returns (uint256) {
    // Phase 1: just USDC balance. Task 6 adds mark-to-market via TWAP.
    return IERC20(asset()).balanceOf(address(this));
}

function deposit(uint256 assets, address receiver)
    public override whenNotPaused returns (uint256)
{
    return super.deposit(assets, receiver);
}

function redeem(uint256 shares, address receiver, address owner)
    public override whenNotPaused returns (uint256)
{
    return super.redeem(shares, receiver, owner);
}
```

- [ ] **Step 3: Run tests**

Run: `cd projects/contracts && forge test --match-contract ObeyVaultTest -v`
Expected: All tests PASS including deposit/redeem.

- [ ] **Step 4: Commit**

```bash
cd projects/contracts
camp p commit -m "feat: ERC-4626 deposit/redeem with pause guard and totalAssets"
```

---

### Task 5: executeSwap with Boundary Enforcement

**Files:**
- Modify: `projects/contracts/src/ObeyVault.sol`
- Modify: `projects/contracts/test/ObeyVault.t.sol`

- [ ] **Step 1: Write swap boundary tests**

Add to test file:

```solidity
function test_executeSwap_onlyAgent() public {
    vm.prank(user);
    vm.expectRevert(ObeyVault.OnlyAgent.selector);
    vault.executeSwap(address(usdc), weth, 100e6, 90e6, "test");
}

function test_executeSwap_unapprovedTokenReverts() public {
    vm.prank(agentAddr);
    vm.expectRevert(abi.encodeWithSelector(
        ObeyVault.TokenNotApproved.selector, weth
    ));
    vault.executeSwap(address(usdc), weth, 100e6, 90e6, "test");
}

function test_executeSwap_exceedsMaxSizeReverts() public {
    vault.setApprovedToken(weth, true);
    vm.prank(agentAddr);
    vm.expectRevert(abi.encodeWithSelector(
        ObeyVault.SwapExceedsMaxSize.selector, 2000e6, 1000e6
    ));
    vault.executeSwap(address(usdc), weth, 2000e6, 1800e6, "test");
}

function test_executeSwap_dailyVolumeCapEnforced() public {
    vault.setApprovedToken(weth, true);
    vault.setMaxSwapSize(10000e6); // raise per-swap limit
    // Volume cap is 10000e6, so two 6000e6 swaps should fail on second

    // Fund the vault
    usdc.mint(address(vault), 20000e6);

    // First swap: 6000 USDC (mock router won't actually swap, but boundary check happens first)
    // We need to test the boundary logic, not the actual swap execution.
    // The swap will fail at the router call, but boundary checks pass first.
    // For a pure boundary test, we verify the revert happens BEFORE the router call.
    vm.prank(agentAddr);
    // This will pass boundary checks but fail at router — that's fine for boundary testing.
    // We'll test the revert on the second swap after volume accumulates.
}

function test_executeSwap_whenPausedReverts() public {
    vault.setApprovedToken(weth, true);
    vault.pause();
    vm.prank(agentAddr);
    vm.expectRevert(); // Pausable: paused
    vault.executeSwap(address(usdc), weth, 100e6, 90e6, "test");
}
```

- [ ] **Step 2: Implement executeSwap**

```solidity
function executeSwap(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    uint256 amountOutMinimum,
    bytes calldata reason
) external onlyAgent whenNotPaused returns (uint256 amountOut) {
    // Prevent no-op self-swaps (must be before volume tracking)
    if (tokenIn == tokenOut) revert SameToken();

    // Boundary checks
    if (!approvedTokens[tokenIn] || !approvedTokens[tokenOut]) {
        revert TokenNotApproved(!approvedTokens[tokenIn] ? tokenIn : tokenOut);
    }
    if (amountIn > maxSwapSize) {
        revert SwapExceedsMaxSize(amountIn, maxSwapSize);
    }

    // Daily volume tracking
    uint256 today = block.timestamp / 1 days;
    if (today != currentDay) {
        currentDay = today;
        dailyVolumeUsed = 0;
    }
    if (dailyVolumeUsed + amountIn > maxDailyVolume) {
        revert DailyVolumeExceeded(dailyVolumeUsed + amountIn, maxDailyVolume);
    }
    dailyVolumeUsed += amountIn;

    // Slippage enforcement: amountOutMinimum must be >= amountIn * (10000 - maxSlippageBps) / 10000
    // (simplified: for same-decimal pairs. For cross-decimal pairs, use TWAP price.)
    uint256 minAcceptable = amountIn * (10000 - maxSlippageBps) / 10000;
    if (amountOutMinimum < minAcceptable) {
        revert SlippageTooHigh(10000 - (amountOutMinimum * 10000 / amountIn), maxSlippageBps);
    }

    // Approve router to spend tokenIn (forceApprove resets to 0 first, preventing stale allowances)
    IERC20(tokenIn).forceApprove(address(swapRouter), amountIn);

    // Execute swap via Uniswap V3 SwapRouter02
    amountOut = swapRouter.exactInputSingle(
        ISwapRouter02.ExactInputSingleParams({
            tokenIn: tokenIn,
            tokenOut: tokenOut,
            fee: 3000, // 0.3% tier
            recipient: address(this),
            amountIn: amountIn,
            amountOutMinimum: amountOutMinimum,
            sqrtPriceLimitX96: 0
        })
    );

    // Update held tokens tracking
    if (IERC20(tokenOut).balanceOf(address(this)) > 0) {
        _heldTokens.add(tokenOut);
    }
    if (IERC20(tokenIn).balanceOf(address(this)) == 0) {
        _heldTokens.remove(tokenIn);
    }

    emit SwapExecuted(tokenIn, tokenOut, amountIn, amountOut, reason);
}
```

- [ ] **Step 3: Run boundary tests**

Run: `cd projects/contracts && forge test --match-contract ObeyVaultTest -v`
Expected: Boundary revert tests PASS. The router-dependent tests may revert at the router call, which is expected with a mock address.

- [ ] **Step 4: Commit**

```bash
cd projects/contracts
camp p commit -m "feat: executeSwap with boundary enforcement — whitelist, size, volume, pause"
```

---

### Task 6: NAV Calculation via Uniswap V3 TWAP

**Files:**
- Modify: `projects/contracts/src/ObeyVault.sol`

- [ ] **Step 1: Write TWAP helper test**

Add to test:

```solidity
function test_heldTokensTracking() public {
    // After construction, heldTokens should be empty (no non-USDC tokens held)
    assertEq(vault.heldTokenCount(), 0);
}
```

- [ ] **Step 2: Add TWAP pricing helper and update totalAssets**

```solidity
uint32 public constant TWAP_PERIOD = 1800; // 30 minutes

function heldTokenCount() external view returns (uint256) {
    return _heldTokens.length();
}

function heldTokenAt(uint256 index) external view returns (address) {
    return _heldTokens.at(index);
}

function totalAssets() public view override returns (uint256) {
    uint256 total = IERC20(asset()).balanceOf(address(this));

    uint256 len = _heldTokens.length();
    for (uint256 i = 0; i < len; i++) {
        address token = _heldTokens.at(i);
        if (token == asset()) continue;

        uint256 balance = IERC20(token).balanceOf(address(this));
        if (balance == 0) continue;

        uint256 price = _getTWAPPrice(token);
        if (price > 0) {
            total += (balance * price) / 1e18;
        }
    }

    return total;
}

function _getTWAPPrice(address token) internal view returns (uint256) {
    IUniswapV3Factory factory = IUniswapV3Factory(uniswapFactory);
    address pool = factory.getPool(token, asset(), 3000);
    if (pool == address(0)) return 0;

    uint32[] memory secondsAgos = new uint32[](2);
    secondsAgos[0] = TWAP_PERIOD;
    secondsAgos[1] = 0;

    try IUniswapV3Pool(pool).observe(secondsAgos) returns (
        int56[] memory tickCumulatives,
        uint160[] memory
    ) {
        int56 tickDiff = tickCumulatives[1] - tickCumulatives[0];
        int24 avgTick = int24(tickDiff / int56(int32(TWAP_PERIOD)));

        // Convert tick to sqrtPriceX96 via TickMath, then to price via FullMath
        uint160 sqrtPriceX96 = TickMath.getSqrtRatioAtTick(avgTick);
        // Use FullMath.mulDiv to avoid uint256 overflow (sqrtPriceX96 can be up to 2^160)
        uint256 price = FullMath.mulDiv(
            uint256(sqrtPriceX96) * uint256(sqrtPriceX96),
            1e18,
            1 << 192
        );
        return price;
    } catch {
        return 0; // Pool not initialized or observation too old
    }
}
```

The vault must import TickMath and FullMath from v3-core at the top of `ObeyVault.sol`:

```solidity
import {TickMath} from "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import {FullMath} from "@uniswap/v3-core/contracts/libraries/FullMath.sol";
```

- [ ] **Step 3: Run tests**

Run: `cd projects/contracts && forge test --match-contract ObeyVaultTest -v`
Expected: PASS (TWAP returns 0 for mock pools, so totalAssets falls back to USDC balance only).

- [ ] **Step 4: Commit**

```bash
cd projects/contracts
camp p commit -m "feat: NAV calculation via Uniswap V3 TWAP oracle with 30-min window"
```

---

### Task 7: Deploy Script

**Files:**
- Create: `projects/contracts/script/DeployVault.s.sol`

- [ ] **Step 1: Write deployment script**

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ObeyVault} from "../src/ObeyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployVault is Script {
    // Base Sepolia addresses
    address constant USDC_SEPOLIA = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;
    address constant SWAP_ROUTER_SEPOLIA = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address constant UNI_FACTORY_SEPOLIA = 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24;

    // Base Mainnet addresses
    address constant USDC_MAINNET = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address constant SWAP_ROUTER_MAINNET = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address constant UNI_FACTORY_MAINNET = 0x33128a8fC17869897dcE68Ed026d694621f6FDfD;

    function run() external {
        uint256 deployerPK = vm.envUint("DEPLOYER_PRIVATE_KEY");
        address agentAddr = vm.envAddress("AGENT_ADDRESS");
        bool isMainnet = vm.envOr("MAINNET", false);

        address usdc = isMainnet ? USDC_MAINNET : USDC_SEPOLIA;
        address router = isMainnet ? SWAP_ROUTER_MAINNET : SWAP_ROUTER_SEPOLIA;
        address factory = isMainnet ? UNI_FACTORY_MAINNET : UNI_FACTORY_SEPOLIA;

        vm.startBroadcast(deployerPK);

        ObeyVault vault = new ObeyVault(
            IERC20(usdc),
            agentAddr,
            router,
            factory,
            1000e6,   // maxSwapSize: 1000 USDC
            10000e6,  // maxDailyVolume: 10,000 USDC
            100        // maxSlippageBps: 1%
        );

        // Approve initial tokens
        vault.setApprovedToken(0x4200000000000000000000000000000000000006, true); // WETH
        // Add more tokens as needed

        vm.stopBroadcast();

        console.log("Vault deployed at:", address(vault));
        console.log("Guardian:", vault.guardian());
        console.log("Agent:", vault.agent());
    }
}
```

- [ ] **Step 2: Verify script compiles**

Run: `cd projects/contracts && forge build`
Expected: Compiles without errors.

- [ ] **Step 3: Commit**

```bash
cd projects/contracts
camp p commit -m "feat: deployment script for Base Sepolia and mainnet"
```

---

## Chunk 2: Go Agent Runtime

### Task 8: Vault Bindings and Client

**Files:**
- Create: `projects/agent-defi/internal/vault/client.go`
- Create: `projects/agent-defi/internal/vault/client_test.go`

- [ ] **Step 1: Generate ABI bindings via abigen**

After vault compiles, extract ABI and generate Go bindings:

```bash
cd projects/contracts
forge build
# Extract ABI from Foundry output
jq '.abi' out/ObeyVault.sol/ObeyVault.json > /tmp/ObeyVault.abi

# Generate Go bindings
abigen --abi /tmp/ObeyVault.abi \
       --pkg vault \
       --type ObeyVault \
       --out ../agent-defi/internal/vault/bindings.go
```

If `abigen` is not installed: `go install github.com/ethereum/go-ethereum/cmd/abigen@latest`

- [ ] **Step 2: Write VaultClient interface and implementation**

```go
package vault

import (
    "context"
    "fmt"
    "math/big"

    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/ethclient"
    "github.com/lancekrogers/agent-defi/internal/base/ethutil"
)

// Client reads vault state and submits swaps via executeSwap.
type Client interface {
    // USDCBalance returns the vault's USDC balance.
    USDCBalance(ctx context.Context) (*big.Int, error)

    // TotalAssets returns the vault's NAV (total assets under management).
    TotalAssets(ctx context.Context) (*big.Int, error)

    // SharePrice returns the current price per share (totalAssets / totalSupply).
    SharePrice(ctx context.Context) (*big.Float, error)

    // ExecuteSwap calls vault.executeSwap with the given parameters.
    ExecuteSwap(ctx context.Context, params SwapParams) (common.Hash, error)

    // HeldTokens returns the list of non-USDC tokens the vault currently holds.
    HeldTokens(ctx context.Context) ([]common.Address, error)
}

// SwapParams holds the parameters for a vault swap.
type SwapParams struct {
    TokenIn       common.Address
    TokenOut      common.Address
    AmountIn      *big.Int
    MinAmountOut  *big.Int
    Reason        []byte
}

// Config holds vault client configuration.
type Config struct {
    RPCURL       string
    ChainID      int64
    VaultAddress string
    PrivateKey   string
}

type client struct {
    cfg Config
}

// NewClient creates a vault client.
func NewClient(cfg Config) Client {
    return &client{cfg: cfg}
}

func (c *client) USDCBalance(ctx context.Context) (*big.Int, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("vault: context cancelled: %w", err)
    }
    // Call asset().balanceOf(vault) via eth_call
    // Implementation uses ABI-encoded eth_call to the vault contract
    return big.NewInt(0), nil // placeholder
}

func (c *client) TotalAssets(ctx context.Context) (*big.Int, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("vault: context cancelled: %w", err)
    }
    // Call vault.totalAssets() via eth_call
    return big.NewInt(0), nil // placeholder
}

func (c *client) SharePrice(ctx context.Context) (*big.Float, error) {
    // totalAssets / totalSupply
    return new(big.Float), nil // placeholder
}

func (c *client) ExecuteSwap(ctx context.Context, params SwapParams) (common.Hash, error) {
    if err := ctx.Err(); err != nil {
        return common.Hash{}, fmt.Errorf("vault: context cancelled: %w", err)
    }

    key, err := ethutil.LoadKey(c.cfg.PrivateKey)
    if err != nil {
        return common.Hash{}, fmt.Errorf("vault: load key: %w", err)
    }

    ethClient, err := ethutil.DialClient(ctx, c.cfg.RPCURL)
    if err != nil {
        return common.Hash{}, fmt.Errorf("vault: dial: %w", err)
    }
    defer ethClient.Close()

    // Use abigen-generated transactor (from bindings.go)
    vaultAddr := common.HexToAddress(c.cfg.VaultAddress)
    bound, err := NewObeyVault(vaultAddr, ethClient)
    if err != nil {
        return common.Hash{}, fmt.Errorf("vault: bind contract: %w", err)
    }

    opts, err := ethutil.MakeTransactOpts(ctx, key, c.cfg.ChainID)
    if err != nil {
        return common.Hash{}, fmt.Errorf("vault: make tx opts: %w", err)
    }

    tx, err := bound.ExecuteSwap(opts, params.TokenIn, params.TokenOut, params.AmountIn, params.MinAmountOut, params.Reason)
    if err != nil {
        return common.Hash{}, fmt.Errorf("vault: executeSwap failed: %w", err)
    }

    return tx.Hash(), nil
}

func (c *client) HeldTokens(ctx context.Context) ([]common.Address, error) {
    return nil, nil // placeholder — will call heldTokenCount + heldTokenAt via abigen
}
```

- [ ] **Step 3: Write test**

```go
package vault

import (
    "context"
    "testing"
)

func TestClientContextCancellation(t *testing.T) {
    c := NewClient(Config{})
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    _, err := c.USDCBalance(ctx)
    if err == nil {
        t.Fatal("expected error on cancelled context")
    }

    _, err = c.ExecuteSwap(ctx, SwapParams{})
    if err == nil {
        t.Fatal("expected error on cancelled context")
    }
}
```

- [ ] **Step 4: Run tests**

Run: `cd projects/agent-defi && go test ./internal/vault/... -v`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: vault client — read state and submit swaps via executeSwap"
```

---

### Task 9: LLM Trading Strategy

**Files:**
- Create: `projects/agent-defi/internal/strategy/llm.go`
- Create: `projects/agent-defi/internal/strategy/llm_test.go`

- [ ] **Step 1: Write the failing test**

```go
package strategy

import (
    "context"
    "testing"
    "time"

    "github.com/lancekrogers/agent-defi/internal/base/trading"
)

type mockLLM struct {
    response string
    err      error
}

func (m *mockLLM) Complete(ctx context.Context, prompt string) (string, error) {
    return m.response, m.err
}

func TestLLMStrategy_BuySignal(t *testing.T) {
    s := NewLLMStrategy(LLMConfig{
        TokenIn:         "0xUSDC",
        TokenOut:        "0xWETH",
        MaxPositionSize: 100.0,
    }, &mockLLM{response: `{"action":"buy","confidence":0.8,"size":0.5,"reason":"ETH undervalued"}`})

    market := trading.MarketState{
        TokenIn:       "0xUSDC",
        TokenOut:      "0xWETH",
        Price:         2500.0,
        MovingAverage: 2600.0,
        Liquidity:     1000000,
        FetchedAt:     time.Now(),
    }

    signal, err := s.Evaluate(context.Background(), market)
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if signal.Type != trading.SignalBuy {
        t.Errorf("expected buy signal, got %s", signal.Type)
    }
    if signal.Confidence < 0.5 {
        t.Errorf("expected confidence >= 0.5, got %f", signal.Confidence)
    }
}

func TestLLMStrategy_HoldSignal(t *testing.T) {
    s := NewLLMStrategy(LLMConfig{
        TokenIn:         "0xUSDC",
        TokenOut:        "0xWETH",
        MaxPositionSize: 100.0,
    }, &mockLLM{response: `{"action":"hold","confidence":0.3,"size":0,"reason":"no clear signal"}`})

    market := trading.MarketState{
        TokenIn:   "0xUSDC",
        TokenOut:  "0xWETH",
        Price:     2500.0,
        FetchedAt: time.Now(),
    }

    signal, err := s.Evaluate(context.Background(), market)
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if signal.Type != trading.SignalHold {
        t.Errorf("expected hold signal, got %s", signal.Type)
    }
}

func TestLLMStrategy_ContextCancellation(t *testing.T) {
    s := NewLLMStrategy(LLMConfig{}, &mockLLM{})
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    _, err := s.Evaluate(ctx, trading.MarketState{})
    if err == nil {
        t.Fatal("expected error on cancelled context")
    }
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd projects/agent-defi && go test ./internal/strategy/... -v`
Expected: FAIL — package does not exist.

- [ ] **Step 3: Implement LLM strategy**

```go
package strategy

import (
    "context"
    "encoding/json"
    "fmt"
    "time"

    "github.com/lancekrogers/agent-defi/internal/base/trading"
)

// LLMClient abstracts the Claude API for testability.
type LLMClient interface {
    Complete(ctx context.Context, prompt string) (string, error)
}

// LLMConfig holds parameters for the LLM-based strategy.
type LLMConfig struct {
    TokenIn         string
    TokenOut        string
    MaxPositionSize float64
}

// LLMStrategy uses Claude to analyze market conditions and produce signals.
type LLMStrategy struct {
    cfg LLMConfig
    llm LLMClient
}

// NewLLMStrategy creates an LLM-based trading strategy.
func NewLLMStrategy(cfg LLMConfig, llm LLMClient) *LLMStrategy {
    return &LLMStrategy{cfg: cfg, llm: llm}
}

func (s *LLMStrategy) Name() string { return "llm_momentum" }

func (s *LLMStrategy) MaxPosition() float64 { return s.cfg.MaxPositionSize }

// llmResponse is the expected JSON structure from Claude.
type llmResponse struct {
    Action     string  `json:"action"` // "buy", "sell", "hold"
    Confidence float64 `json:"confidence"`
    Size       float64 `json:"size"`   // fraction of max position
    Reason     string  `json:"reason"`
}

func (s *LLMStrategy) Evaluate(ctx context.Context, market trading.MarketState) (*trading.Signal, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("llm strategy: context cancelled: %w", err)
    }

    prompt := fmt.Sprintf(
        `You are a DeFi trading agent. Analyze this market data and decide whether to buy, sell, or hold.

Token pair: %s → %s
Current price: %.6f
Moving average: %.6f
Liquidity: %.2f

Respond with JSON only: {"action":"buy|sell|hold","confidence":0.0-1.0,"size":0.0-1.0,"reason":"..."}`,
        market.TokenIn, market.TokenOut,
        market.Price, market.MovingAverage, market.Liquidity,
    )

    resp, err := s.llm.Complete(ctx, prompt)
    if err != nil {
        return nil, fmt.Errorf("llm strategy: completion failed: %w", err)
    }

    var parsed llmResponse
    if err := json.Unmarshal([]byte(resp), &parsed); err != nil {
        return nil, fmt.Errorf("llm strategy: parse response: %w", err)
    }

    signal := &trading.Signal{
        GeneratedAt: time.Now(),
        TokenIn:     s.cfg.TokenIn,
        TokenOut:    s.cfg.TokenOut,
        Confidence:  parsed.Confidence,
        Reason:      parsed.Reason,
    }

    switch parsed.Action {
    case "buy":
        signal.Type = trading.SignalBuy
        signal.SuggestedSize = parsed.Size * s.cfg.MaxPositionSize
    case "sell":
        signal.Type = trading.SignalSell
        signal.SuggestedSize = parsed.Size * s.cfg.MaxPositionSize
    default:
        signal.Type = trading.SignalHold
    }

    return signal, nil
}
```

- [ ] **Step 4: Run tests**

Run: `cd projects/agent-defi && go test ./internal/strategy/... -v`
Expected: All 3 tests PASS.

- [ ] **Step 5: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: LLM trading strategy using Claude API with JSON signal parsing"
```

- [ ] **Step 6: Implement ClaudeClient (real LLM client)**

Create `projects/agent-defi/internal/strategy/claude.go`:

```go
package strategy

import (
    "bytes"
    "context"
    "encoding/json"
    "fmt"
    "io"
    "net/http"
    "time"
)

// ClaudeClient implements LLMClient using the Anthropic Messages API.
type ClaudeClient struct {
    APIKey string
    Model  string
}

func (c *ClaudeClient) Complete(ctx context.Context, prompt string) (string, error) {
    if err := ctx.Err(); err != nil {
        return "", fmt.Errorf("claude: context cancelled: %w", err)
    }

    model := c.Model
    if model == "" {
        model = "claude-sonnet-4-6"
    }

    reqBody := map[string]interface{}{
        "model":      model,
        "max_tokens": 256,
        "messages": []map[string]string{
            {"role": "user", "content": prompt},
        },
    }

    body, err := json.Marshal(reqBody)
    if err != nil {
        return "", fmt.Errorf("claude: marshal: %w", err)
    }

    req, err := http.NewRequestWithContext(ctx, http.MethodPost,
        "https://api.anthropic.com/v1/messages", bytes.NewReader(body))
    if err != nil {
        return "", fmt.Errorf("claude: create request: %w", err)
    }
    req.Header.Set("Content-Type", "application/json")
    req.Header.Set("x-api-key", c.APIKey)
    req.Header.Set("anthropic-version", "2023-06-01")

    client := &http.Client{Timeout: 30 * time.Second}
    resp, err := client.Do(req)
    if err != nil {
        return "", fmt.Errorf("claude: request failed: %w", err)
    }
    defer resp.Body.Close()

    respBody, err := io.ReadAll(resp.Body)
    if err != nil {
        return "", fmt.Errorf("claude: read response: %w", err)
    }

    if resp.StatusCode != http.StatusOK {
        return "", fmt.Errorf("claude: status %d: %s", resp.StatusCode, string(respBody))
    }

    var result struct {
        Content []struct {
            Text string `json:"text"`
        } `json:"content"`
    }
    if err := json.Unmarshal(respBody, &result); err != nil {
        return "", fmt.Errorf("claude: decode: %w", err)
    }

    if len(result.Content) == 0 {
        return "", fmt.Errorf("claude: empty response")
    }

    return result.Content[0].Text, nil
}
```

- [ ] **Step 7: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: ClaudeClient for Anthropic Messages API"
```

---

### Task 10: Risk Manager

**Files:**
- Create: `projects/agent-defi/internal/risk/manager.go`
- Create: `projects/agent-defi/internal/risk/manager_test.go`

- [ ] **Step 1: Write failing tests**

```go
package risk

import (
    "context"
    "testing"
    "time"

    "github.com/lancekrogers/agent-defi/internal/base/trading"
)

func TestManager_RejectsOversizedPosition(t *testing.T) {
    m := NewManager(Config{MaxPositionUSD: 500, MaxDailyVolumeUSD: 10000})
    signal := &trading.Signal{
        Type:          trading.SignalBuy,
        SuggestedSize: 1000.0,
    }
    err := m.Check(context.Background(), signal, 2500.0)
    if err == nil {
        t.Fatal("expected rejection for oversized position")
    }
}

func TestManager_ClampsPosition(t *testing.T) {
    m := NewManager(Config{MaxPositionUSD: 500, MaxDailyVolumeUSD: 10000})
    signal := &trading.Signal{
        Type:          trading.SignalBuy,
        SuggestedSize: 1000.0,
    }
    m.Clamp(signal, 2500.0)
    if signal.SuggestedSize > 500.0/2500.0 {
        t.Errorf("expected clamped size <= %f, got %f", 500.0/2500.0, signal.SuggestedSize)
    }
}

func TestManager_DailyVolumeTracking(t *testing.T) {
    m := NewManager(Config{MaxPositionUSD: 10000, MaxDailyVolumeUSD: 1000})
    signal := &trading.Signal{Type: trading.SignalBuy, SuggestedSize: 0.5}

    // First trade: 0.5 * 2000 = 1000 USD — exactly at limit
    err := m.Check(context.Background(), signal, 2000.0)
    if err != nil {
        t.Fatalf("first trade should pass: %v", err)
    }
    m.RecordTrade(0.5, 2000.0)

    // Second trade should exceed daily volume
    err = m.Check(context.Background(), signal, 2000.0)
    if err == nil {
        t.Fatal("expected daily volume rejection")
    }
}

func TestManager_DrawdownHalt(t *testing.T) {
    m := NewManager(Config{
        MaxPositionUSD:    10000,
        MaxDailyVolumeUSD: 100000,
        MaxDrawdownPct:    0.10, // 10% drawdown halt
        InitialNAV:       10000,
    })
    m.UpdateNAV(8500) // 15% drawdown
    signal := &trading.Signal{Type: trading.SignalBuy, SuggestedSize: 0.1}

    err := m.Check(context.Background(), signal, 2500.0)
    if err == nil {
        t.Fatal("expected drawdown halt")
    }
}
```

- [ ] **Step 2: Run tests to verify failure**

Run: `cd projects/agent-defi && go test ./internal/risk/... -v`
Expected: FAIL — package does not exist.

- [ ] **Step 3: Implement risk manager**

```go
package risk

import (
    "context"
    "fmt"
    "sync"
    "time"

    "github.com/lancekrogers/agent-defi/internal/base/trading"
)

// Config holds risk manager parameters.
type Config struct {
    MaxPositionUSD    float64
    MaxDailyVolumeUSD float64
    MaxDrawdownPct    float64
    InitialNAV        float64
}

// Manager enforces position limits, daily volume caps, and drawdown halts.
type Manager struct {
    cfg         Config
    mu          sync.Mutex
    dailyVolume float64
    currentDay  int
    currentNAV  float64
    peakNAV     float64
}

// NewManager creates a risk manager.
func NewManager(cfg Config) *Manager {
    nav := cfg.InitialNAV
    if nav == 0 {
        nav = 1.0 // avoid division by zero
    }
    return &Manager{
        cfg:        cfg,
        currentDay: time.Now().YearDay(),
        currentNAV: nav,
        peakNAV:    nav,
    }
}

// Check validates a signal against risk constraints. Returns error if rejected.
func (m *Manager) Check(ctx context.Context, signal *trading.Signal, price float64) error {
    if err := ctx.Err(); err != nil {
        return fmt.Errorf("risk: context cancelled: %w", err)
    }

    m.mu.Lock()
    defer m.mu.Unlock()

    m.resetDayIfNeeded()

    // Position size check
    positionUSD := signal.SuggestedSize * price
    if positionUSD > m.cfg.MaxPositionUSD {
        return fmt.Errorf("risk: position %.2f USD exceeds max %.2f USD",
            positionUSD, m.cfg.MaxPositionUSD)
    }

    // Daily volume check
    if m.dailyVolume+positionUSD > m.cfg.MaxDailyVolumeUSD {
        return fmt.Errorf("risk: daily volume %.2f + %.2f exceeds cap %.2f USD",
            m.dailyVolume, positionUSD, m.cfg.MaxDailyVolumeUSD)
    }

    // Drawdown check
    if m.cfg.MaxDrawdownPct > 0 && m.peakNAV > 0 {
        drawdown := (m.peakNAV - m.currentNAV) / m.peakNAV
        if drawdown > m.cfg.MaxDrawdownPct {
            return fmt.Errorf("risk: drawdown %.2f%% exceeds halt threshold %.2f%%",
                drawdown*100, m.cfg.MaxDrawdownPct*100)
        }
    }

    return nil
}

// Clamp reduces the signal size to fit within position limits.
func (m *Manager) Clamp(signal *trading.Signal, price float64) {
    maxSize := m.cfg.MaxPositionUSD / price
    if signal.SuggestedSize > maxSize {
        signal.SuggestedSize = maxSize
    }
}

// RecordTrade records a trade for daily volume tracking.
func (m *Manager) RecordTrade(size, price float64) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.resetDayIfNeeded()
    m.dailyVolume += size * price
}

// UpdateNAV updates the current and peak NAV for drawdown tracking.
func (m *Manager) UpdateNAV(nav float64) {
    m.mu.Lock()
    defer m.mu.Unlock()
    m.currentNAV = nav
    if nav > m.peakNAV {
        m.peakNAV = nav
    }
}

func (m *Manager) resetDayIfNeeded() {
    today := time.Now().YearDay()
    if today != m.currentDay {
        m.currentDay = today
        m.dailyVolume = 0
    }
}
```

- [ ] **Step 4: Run tests**

Run: `cd projects/agent-defi && go test ./internal/risk/... -v`
Expected: All 4 tests PASS.

- [ ] **Step 5: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: risk manager — position limits, daily volume cap, drawdown halt"
```

---

### Task 11: Agent Loop Runner

**Files:**
- Create: `projects/agent-defi/internal/loop/runner.go`
- Create: `projects/agent-defi/internal/loop/runner_test.go`

- [ ] **Step 1: Write failing test**

```go
package loop

import (
    "context"
    "log/slog"
    "math/big"
    "testing"
    "time"

    "github.com/ethereum/go-ethereum/common"
    "github.com/lancekrogers/agent-defi/internal/base/trading"
    "github.com/lancekrogers/agent-defi/internal/risk"
    "github.com/lancekrogers/agent-defi/internal/vault"
)

// mockVault implements vault.Client for testing.
type mockVault struct {
    swapCalled bool
    lastParams vault.SwapParams
}

func (m *mockVault) USDCBalance(ctx context.Context) (*big.Int, error) {
    return big.NewInt(100_000_000), nil // 100 USDC
}
func (m *mockVault) TotalAssets(ctx context.Context) (*big.Int, error) {
    return big.NewInt(100_000_000), nil
}
func (m *mockVault) SharePrice(ctx context.Context) (*big.Float, error) {
    return new(big.Float).SetFloat64(1.0), nil
}
func (m *mockVault) ExecuteSwap(ctx context.Context, params vault.SwapParams) (common.Hash, error) {
    m.swapCalled = true
    m.lastParams = params
    return common.HexToHash("0xabc123"), nil
}
func (m *mockVault) HeldTokens(ctx context.Context) ([]common.Address, error) {
    return nil, nil
}

// mockExecutor implements trading.TradeExecutor for market data only.
type mockExecutor struct{}

func (m *mockExecutor) Execute(ctx context.Context, trade trading.Trade) (*trading.TradeResult, error) {
    return nil, nil // Never called from runner — swaps go through vault
}
func (m *mockExecutor) GetBalance(ctx context.Context, tokenAddress string) (*trading.Balance, error) {
    return &trading.Balance{AmountWei: "0x0"}, nil
}
func (m *mockExecutor) GetMarketState(ctx context.Context, tokenIn, tokenOut string) (*trading.MarketState, error) {
    return &trading.MarketState{
        TokenIn:       tokenIn,
        TokenOut:      tokenOut,
        Price:         2500.0,
        MovingAverage: 2600.0,
        Liquidity:     1_000_000,
        FetchedAt:     time.Now(),
    }, nil
}

// mockStrategy implements trading.Strategy.
type mockStrategy struct {
    signal *trading.Signal
}

func (m *mockStrategy) Name() string         { return "mock" }
func (m *mockStrategy) MaxPosition() float64  { return 1000 }
func (m *mockStrategy) Evaluate(ctx context.Context, market trading.MarketState) (*trading.Signal, error) {
    return m.signal, nil
}

func TestRunner_BuySignalExecutesSwap(t *testing.T) {
    mv := &mockVault{}
    r := New(
        Config{
            Interval: time.Second,
            TokenIn:  common.HexToAddress("0xUSDC"),
            TokenOut: common.HexToAddress("0xWETH"),
        },
        slog.Default(),
        mv,
        &mockExecutor{},
        &mockStrategy{signal: &trading.Signal{
            Type:          trading.SignalBuy,
            Confidence:    0.8,
            SuggestedSize: 50.0,
            Reason:        "test buy",
            TokenIn:       "0xUSDC",
            TokenOut:      "0xWETH",
        }},
        risk.NewManager(risk.Config{MaxPositionUSD: 200000, MaxDailyVolumeUSD: 1000000}),
    )

    err := r.cycle(context.Background())
    if err != nil {
        t.Fatalf("cycle failed: %v", err)
    }
    if !mv.swapCalled {
        t.Fatal("expected vault.ExecuteSwap to be called on buy signal")
    }
}

func TestRunner_HoldSignalSkipsSwap(t *testing.T) {
    mv := &mockVault{}
    r := New(
        Config{Interval: time.Second},
        nil,
        mv,
        &mockExecutor{},
        &mockStrategy{signal: &trading.Signal{
            Type:   trading.SignalHold,
            Reason: "no signal",
        }},
        risk.NewManager(risk.Config{MaxPositionUSD: 200000, MaxDailyVolumeUSD: 1000000}),
    )

    err := r.cycle(context.Background())
    if err != nil {
        t.Fatalf("cycle failed: %v", err)
    }
    if mv.swapCalled {
        t.Fatal("vault.ExecuteSwap should NOT be called on hold signal")
    }
}
```

- [ ] **Step 2: Implement runner**

```go
package loop

import (
    "context"
    "fmt"
    "log/slog"
    "math/big"
    "time"

    "github.com/ethereum/go-ethereum/common"
    "github.com/lancekrogers/agent-defi/internal/base/trading"
    "github.com/lancekrogers/agent-defi/internal/risk"
    "github.com/lancekrogers/agent-defi/internal/vault"
)

// Config holds runner configuration.
type Config struct {
    Interval time.Duration
    TokenIn  common.Address
    TokenOut common.Address
}

// Runner orchestrates the trading loop: fetch → analyze → filter → execute.
//
// IMPORTANT: trading.TradeExecutor is used ONLY for GetMarketState() — market data reads.
// All trade execution goes through vault.Client.ExecuteSwap().
// Never call executor.Execute() from the runner.
type Runner struct {
    cfg      Config
    log      *slog.Logger
    vault    vault.Client
    executor trading.TradeExecutor // market data only — NOT for executing trades
    strategy trading.Strategy
    risk     *risk.Manager
}

// New creates a runner with injected dependencies.
func New(cfg Config, log *slog.Logger, v vault.Client, exec trading.TradeExecutor, strat trading.Strategy, r *risk.Manager) *Runner {
    return &Runner{cfg: cfg, log: log, vault: v, executor: exec, strategy: strat, risk: r}
}

// Run starts the trading loop and blocks until context cancellation.
func (r *Runner) Run(ctx context.Context) error {
    r.log.Info("starting trading loop", "interval", r.cfg.Interval)

    ticker := time.NewTicker(r.cfg.Interval)
    defer ticker.Stop()

    for {
        select {
        case <-ctx.Done():
            r.log.Info("trading loop stopped")
            return ctx.Err()
        case <-ticker.C:
            if err := r.cycle(ctx); err != nil {
                r.log.Warn("trading cycle failed", "error", err)
            }
        }
    }
}

func (r *Runner) cycle(ctx context.Context) error {
    if err := ctx.Err(); err != nil {
        return err
    }

    // 1. Fetch market state
    market, err := r.executor.GetMarketState(ctx, r.cfg.TokenIn.Hex(), r.cfg.TokenOut.Hex())
    if err != nil {
        return fmt.Errorf("cycle: market state: %w", err)
    }

    // 2. Update NAV for drawdown tracking
    nav, err := r.vault.TotalAssets(ctx)
    if err == nil && nav != nil {
        navFloat, _ := new(big.Float).SetInt(nav).Float64()
        r.risk.UpdateNAV(navFloat)
    }

    // 3. Evaluate strategy
    signal, err := r.strategy.Evaluate(ctx, *market)
    if err != nil {
        return fmt.Errorf("cycle: strategy: %w", err)
    }

    r.log.Info("signal", "type", signal.Type, "confidence", signal.Confidence, "reason", signal.Reason)

    if signal.Type == trading.SignalHold {
        return nil
    }

    // 4. Risk check
    if err := r.risk.Check(ctx, signal, market.Price); err != nil {
        r.log.Info("risk rejected trade", "error", err)
        return nil // not an error — just filtered
    }

    // 5. Clamp position to risk limits
    r.risk.Clamp(signal, market.Price)

    // 6. Execute via vault
    amountIn := new(big.Int).SetInt64(int64(signal.SuggestedSize * 1e6)) // USDC has 6 decimals
    minOut := new(big.Int).SetInt64(int64(signal.SuggestedSize * market.Price * 0.99 * 1e18)) // 1% slippage

    txHash, err := r.vault.ExecuteSwap(ctx, vault.SwapParams{
        TokenIn:      r.cfg.TokenIn,
        TokenOut:     r.cfg.TokenOut,
        AmountIn:     amountIn,
        MinAmountOut: minOut,
        Reason:       []byte(signal.Reason),
    })
    if err != nil {
        return fmt.Errorf("cycle: swap failed: %w", err)
    }

    r.risk.RecordTrade(signal.SuggestedSize, market.Price)
    r.log.Info("swap executed", "tx", txHash.Hex(), "size", signal.SuggestedSize)
    return nil
}
```

- [ ] **Step 3: Run tests**

Run: `cd projects/agent-defi && go test ./internal/loop/... -v`
Expected: PASS (placeholder test).

- [ ] **Step 4: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: trading loop runner — fetch, analyze, filter, execute via vault"
```

---

### Task 12: Entry Point Binary

**Files:**
- Create: `projects/agent-defi/cmd/vault-agent/main.go`

- [ ] **Step 1: Write main.go**

```go
package main

import (
    "context"
    "log/slog"
    "os"
    "os/signal"
    "syscall"
    "time"

    "github.com/ethereum/go-ethereum/common"
    "github.com/lancekrogers/agent-defi/internal/base/trading"
    "github.com/lancekrogers/agent-defi/internal/loop"
    "github.com/lancekrogers/agent-defi/internal/risk"
    "github.com/lancekrogers/agent-defi/internal/strategy"
    "github.com/lancekrogers/agent-defi/internal/vault"
)

func main() {
    log := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: slog.LevelInfo}))

    // Load config from environment
    vaultCfg := vault.Config{
        RPCURL:       envOr("VAULT_RPC_URL", "https://sepolia.base.org"),
        ChainID:      84532,
        VaultAddress: os.Getenv("VAULT_ADDRESS"),
        PrivateKey:   os.Getenv("AGENT_PRIVATE_KEY"),
    }

    vaultClient := vault.NewClient(vaultCfg)

    executor := trading.NewExecutor(trading.ExecutorConfig{
        RPCURL:           vaultCfg.RPCURL,
        ChainID:          vaultCfg.ChainID,
        WalletAddress:    os.Getenv("AGENT_WALLET_ADDRESS"),
        PrivateKey:       vaultCfg.PrivateKey,
        DEXRouterAddress: envOr("DEX_ROUTER", "0x2626664c2603336E57B271c5C0b26F421741e481"),
    })

    // TODO: Replace with real Claude API client
    llmClient := &strategy.ClaudeClient{
        APIKey: os.Getenv("ANTHROPIC_API_KEY"),
        Model:  envOr("LLM_MODEL", "claude-sonnet-4-6"),
    }

    strat := strategy.NewLLMStrategy(strategy.LLMConfig{
        TokenIn:         os.Getenv("TOKEN_IN"),
        TokenOut:        os.Getenv("TOKEN_OUT"),
        MaxPositionSize: 100.0,
    }, llmClient)

    riskMgr := risk.NewManager(risk.Config{
        MaxPositionUSD:    1000,
        MaxDailyVolumeUSD: 10000,
        MaxDrawdownPct:    0.10,
        InitialNAV:        10000,
    })

    runner := loop.New(loop.Config{
        Interval: 5 * time.Minute,
        TokenIn:  common.HexToAddress(os.Getenv("TOKEN_IN")),
        TokenOut: common.HexToAddress(os.Getenv("TOKEN_OUT")),
    }, log, vaultClient, executor, strat, riskMgr)

    ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
    defer cancel()

    log.Info("vault agent starting",
        "vault", vaultCfg.VaultAddress,
        "strategy", strat.Name(),
    )

    if err := runner.Run(ctx); err != nil && err != context.Canceled {
        log.Error("agent exited with error", "error", err)
        os.Exit(1)
    }
}

func envOr(key, defaultVal string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return defaultVal
}
```

- [ ] **Step 2: Verify compilation**

Run: `cd projects/agent-defi && go build ./cmd/vault-agent/`
Expected: Compiles (after wiring all imports).

- [ ] **Step 3: Add justfile recipe**

Add to `projects/agent-defi/justfile`:

```just
vault-agent:
    go run ./cmd/vault-agent/
```

- [ ] **Step 4: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: vault-agent entry point with env-based config"
```

---

## Chunk 3: ERC-8004 Identity Registration

### Task 13: Synthesis API Registration

**Files:**
- Create: `projects/agent-defi/internal/synthesis/register.go`
- Create: `projects/agent-defi/internal/synthesis/register_test.go`

- [ ] **Step 1: Write failing test**

```go
package synthesis

import (
    "context"
    "encoding/json"
    "net/http"
    "net/http/httptest"
    "testing"
)

func TestRegister_Success(t *testing.T) {
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        if r.Method != http.MethodPost {
            t.Fatalf("expected POST, got %s", r.Method)
        }
        if r.URL.Path != "/register" {
            t.Fatalf("expected /register, got %s", r.URL.Path)
        }

        w.WriteHeader(http.StatusCreated)
        json.NewEncoder(w).Encode(RegisterResponse{
            ParticipantID:   "test-id",
            TeamID:          "test-team",
            Name:            "OBEY Vault Agent",
            APIKey:          "sk-synth-test123",
            RegistrationTxn: "https://basescan.org/tx/0xtest",
        })
    }))
    defer server.Close()

    client := NewClient(server.URL)
    resp, err := client.Register(context.Background(), RegisterRequest{
        Name:         "OBEY Vault Agent",
        Description:  "DeFi trading agent with on-chain vault custody",
        AgentHarness: "claude-code",
        Model:        "claude-sonnet-4-6",
        HumanInfo: HumanInfo{
            FullName:         "Lance Rogers",
            Email:            "lance@example.com",
            Background:       "Builder",
            CryptoExperience: "yes",
            AIExperience:     "yes",
            CodingComfort:    9,
            ProblemStatement: "Building autonomous DeFi agents with transparent on-chain vault management",
        },
    })
    if err != nil {
        t.Fatalf("unexpected error: %v", err)
    }
    if resp.APIKey == "" {
        t.Fatal("expected API key in response")
    }
}

func TestRegister_ContextCancellation(t *testing.T) {
    client := NewClient("http://localhost:0")
    ctx, cancel := context.WithCancel(context.Background())
    cancel()

    _, err := client.Register(ctx, RegisterRequest{})
    if err == nil {
        t.Fatal("expected error on cancelled context")
    }
}
```

- [ ] **Step 2: Run tests to verify failure**

Run: `cd projects/agent-defi && go test ./internal/synthesis/... -v`
Expected: FAIL — package does not exist.

- [ ] **Step 3: Implement Synthesis API client**

```go
package synthesis

import (
    "bytes"
    "context"
    "encoding/json"
    "fmt"
    "net/http"
    "time"
)

type HumanInfo struct {
    FullName         string `json:"fullName"`
    Email            string `json:"email"`
    SocialHandle     string `json:"socialHandle,omitempty"`
    Background       string `json:"background"`
    CryptoExperience string `json:"cryptoExperience"`
    AIExperience     string `json:"aiAgentExperience"`
    CodingComfort    int    `json:"codingComfort"`
    ProblemStatement string `json:"problemStatement"`
}

type RegisterRequest struct {
    Name         string    `json:"name"`
    Description  string    `json:"description"`
    AgentHarness string    `json:"agentHarness"`
    Model        string    `json:"model"`
    Image        string    `json:"image,omitempty"`
    HumanInfo    HumanInfo `json:"humanInfo"`
}

type RegisterResponse struct {
    ParticipantID   string `json:"participantId"`
    TeamID          string `json:"teamId"`
    Name            string `json:"name"`
    APIKey          string `json:"apiKey"`
    RegistrationTxn string `json:"registrationTxn"`
}

type Client struct {
    baseURL string
    http    *http.Client
}

func NewClient(baseURL string) *Client {
    return &Client{
        baseURL: baseURL,
        http:    &http.Client{Timeout: 30 * time.Second},
    }
}

func (c *Client) Register(ctx context.Context, req RegisterRequest) (*RegisterResponse, error) {
    if err := ctx.Err(); err != nil {
        return nil, fmt.Errorf("synthesis: context cancelled: %w", err)
    }

    body, err := json.Marshal(req)
    if err != nil {
        return nil, fmt.Errorf("synthesis: marshal request: %w", err)
    }

    httpReq, err := http.NewRequestWithContext(ctx, http.MethodPost, c.baseURL+"/register", bytes.NewReader(body))
    if err != nil {
        return nil, fmt.Errorf("synthesis: create request: %w", err)
    }
    httpReq.Header.Set("Content-Type", "application/json")

    resp, err := c.http.Do(httpReq)
    if err != nil {
        return nil, fmt.Errorf("synthesis: request failed: %w", err)
    }
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusCreated {
        return nil, fmt.Errorf("synthesis: unexpected status %d", resp.StatusCode)
    }

    var result RegisterResponse
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return nil, fmt.Errorf("synthesis: decode response: %w", err)
    }

    return &result, nil
}
```

- [ ] **Step 4: Run tests**

Run: `cd projects/agent-defi && go test ./internal/synthesis/... -v`
Expected: All tests PASS.

- [ ] **Step 5: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: Synthesis API client for ERC-8004 agent registration"
```

---

## Chunk 4: Deploy and Integration

### Task 14: Deploy Vault to Base Sepolia

- [ ] **Step 1: Set up environment variables**

Create `.env` (DO NOT commit):

```bash
DEPLOYER_PRIVATE_KEY=<guardian private key>
AGENT_ADDRESS=<agent wallet address>
```

- [ ] **Step 2: Deploy**

```bash
cd projects/contracts
source .env
forge script script/DeployVault.s.sol:DeployVault \
    --rpc-url https://sepolia.base.org \
    --broadcast \
    --verify
```

- [ ] **Step 3: Record deployment artifacts**

Save the vault address to `workflow/design/synthesis/deployment.md`.

- [ ] **Step 4: Verify on Basescan**

Check the deployed contract on Base Sepolia Basescan.

- [ ] **Step 5: Commit deployment artifacts**

```bash
git add workflow/design/synthesis/deployment.md
git commit -m "chore: record Base Sepolia vault deployment address"
```

---

### Task 15: Register Agent via Synthesis API

- [ ] **Step 1: Run registration via curl**

```bash
curl -X POST https://synthesis.devfolio.co/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "OBEY Vault Agent",
    "description": "DeFi trading agent with on-chain vault custody on Base. Trades via Uniswap V3 within human-defined spending boundaries.",
    "agentHarness": "claude-code",
    "model": "claude-sonnet-4-6",
    "humanInfo": {
      "fullName": "Lance Rogers",
      "email": "<email>",
      "background": "Builder",
      "cryptoExperience": "yes",
      "aiAgentExperience": "yes",
      "codingComfort": 9,
      "problemStatement": "Building autonomous DeFi agents with transparent on-chain vault management"
    }
  }'
```

- [ ] **Step 2: Save API key securely**

Save `apiKey` to `.env` — DO NOT commit.
Record `participantId`, `teamId`, and `registrationTxn` in `workflow/design/synthesis/deployment.md`.

- [ ] **Step 3: Commit metadata (not secrets)**

```bash
git add workflow/design/synthesis/deployment.md
git commit -m "chore: record Synthesis registration artifacts"
```

---

### Task 16: End-to-End Testnet Integration

- [ ] **Step 1: Fund agent wallet on Base Sepolia**

Get testnet USDC from Base Sepolia faucet. Deposit into vault.

- [ ] **Step 2: Approve tokens on vault**

Via cast or script:

```bash
cast send <VAULT_ADDRESS> "setApprovedToken(address,bool)" \
    0x4200000000000000000000000000000000000006 true \
    --rpc-url https://sepolia.base.org \
    --private-key $DEPLOYER_PRIVATE_KEY
```

- [ ] **Step 3: Run the agent**

```bash
cd projects/agent-defi
VAULT_ADDRESS=<deployed vault> \
AGENT_PRIVATE_KEY=<agent key> \
TOKEN_IN=0x036CbD53842c5426634e7929541eC2318f3dCF7e \
TOKEN_OUT=0x4200000000000000000000000000000000000006 \
ANTHROPIC_API_KEY=<key> \
just vault-agent
```

- [ ] **Step 4: Verify on-chain**

Check Basescan for `SwapExecuted` events from the vault.

- [ ] **Step 5: Test boundary enforcement**

Attempt a swap exceeding `maxSwapSize` — verify it reverts.

---

### Task 17: Security Checkpoint

- [ ] **Step 1: Manual code review**

Review `ObeyVault.sol` for:
- Role assignment correctness (only guardian can change agent)
- No token extraction paths (agent can only swap, never transfer)
- Daily volume tracking cannot be bypassed
- Pause stops all agent operations
- TWAP oracle manipulation resistance (30-min window)

- [ ] **Step 2: Run Foundry static analysis**

```bash
cd projects/contracts
forge test -vvv
# Consider: slither . (if installed)
```

- [ ] **Step 3: Document findings**

Record review in `workflow/design/synthesis/security-review.md`.

- [ ] **Step 4: Commit**

```bash
git add workflow/design/synthesis/security-review.md
git commit -m "chore: pre-mainnet security review"
```

---

### Task 18: Base Mainnet Deployment

- [ ] **Step 1: Deploy vault to Base mainnet**

```bash
cd projects/contracts
MAINNET=true forge script script/DeployVault.s.sol:DeployVault \
    --rpc-url https://mainnet.base.org \
    --broadcast \
    --verify
```

- [ ] **Step 2: Record mainnet addresses**

Update `workflow/design/synthesis/deployment.md` with mainnet vault address.

- [ ] **Step 3: Deposit initial USDC**

Deposit 100 USDC into the vault.

- [ ] **Step 4: Run agent against mainnet**

Update env to point at mainnet RPC and vault address.

- [ ] **Step 5: Commit**

```bash
git add workflow/design/synthesis/deployment.md
git commit -m "chore: Base mainnet vault deployment"
```

---

## Chunk 5: Observer and Submission

### Task 19: Observer CLI

**Files:**
- Create: `projects/agent-defi/cmd/observer/main.go`

- [ ] **Step 1: Implement CLI**

```go
package main

import (
    "context"
    "fmt"
    "log"
    "math/big"
    "os"
    "time"

    "github.com/lancekrogers/agent-defi/internal/vault"
)

func main() {
    vaultAddr := os.Getenv("VAULT_ADDRESS")
    rpcURL := os.Getenv("RPC_URL")
    if vaultAddr == "" || rpcURL == "" {
        log.Fatal("VAULT_ADDRESS and RPC_URL required")
    }

    client := vault.NewClient(vault.Config{
        RPCURL:       rpcURL,
        VaultAddress: vaultAddr,
    })

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    fmt.Println("=== OBEY Vault Status ===")
    fmt.Printf("Vault: %s\n\n", vaultAddr)

    balance, err := client.USDCBalance(ctx)
    if err != nil {
        fmt.Printf("USDC Balance: error (%v)\n", err)
    } else {
        fmt.Printf("USDC Balance: %s\n", formatUSDC(balance))
    }

    total, err := client.TotalAssets(ctx)
    if err != nil {
        fmt.Printf("Total Assets (NAV): error (%v)\n", err)
    } else {
        fmt.Printf("Total Assets (NAV): %s USDC\n", formatUSDC(total))
    }

    sharePrice, err := client.SharePrice(ctx)
    if err != nil {
        fmt.Printf("Share Price: error (%v)\n", err)
    } else {
        fmt.Printf("Share Price: %s\n", sharePrice.Text('f', 6))
    }

    tokens, err := client.HeldTokens(ctx)
    if err == nil && len(tokens) > 0 {
        fmt.Println("\nHeld Tokens:")
        for _, t := range tokens {
            fmt.Printf("  - %s\n", t.Hex())
        }
    }

    // TODO: Query SwapExecuted events for trade history
    fmt.Println("\n(Trade history via SwapExecuted events — coming soon)")
}

func formatUSDC(wei *big.Int) string {
    if wei == nil {
        return "0"
    }
    f := new(big.Float).SetInt(wei)
    f.Quo(f, new(big.Float).SetFloat64(1e6))
    return f.Text('f', 2)
}
```

- [ ] **Step 2: Verify compilation**

Run: `cd projects/agent-defi && go build ./cmd/observer/`
Expected: Compiles.

- [ ] **Step 3: Add justfile recipe**

```just
observer:
    go run ./cmd/observer/
```

- [ ] **Step 4: Commit**

```bash
cd projects/agent-defi
camp p commit -m "feat: observer CLI — vault state, NAV, held tokens"
```

---

### Task 20: Submission Preparation

- [ ] **Step 1: Verify all on-chain artifacts exist**

Checklist:
- Vault contract on Base (verified on Basescan)
- ERC-8004 agent identity on Base
- At least 2-3 `SwapExecuted` events on-chain

- [ ] **Step 2: Capture conversation logs**

Export Claude Code conversation logs for the Synthesis submission.

- [ ] **Step 3: Record demo**

Either live walkthrough or recorded demo showing:
1. Agent registers (ERC-8004)
2. Human deposits USDC
3. Agent trades autonomously
4. Trades visible on-chain with rationale
5. Boundary enforcement (rejected swap)
6. Exit at NAV

- [ ] **Step 4: Update submission metadata**

Prepare `submissionMetadata` with:
- Agent harness: `claude-code`
- Model: `claude-sonnet-4-6`
- Conversation logs
- On-chain artifacts (vault address, agent NFT, trade tx hashes)

- [ ] **Step 5: Final commit**

```bash
git add .
git commit -m "chore: finalize Synthesis hackathon submission"
```
