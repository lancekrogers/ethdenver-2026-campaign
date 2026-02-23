---
fest_type: task
fest_id: 01_implement_erc7857_contract.md
fest_name: implement erc7857 contract
fest_parent: 02_erc7857_inft_contract
fest_order: 1
fest_status: completed
fest_autonomy: medium
fest_created: 2026-02-21T17:49:14.760257-07:00
fest_updated: 2026-02-23T13:42:00.462014-07:00
fest_tracking: true
---


# Task: Implement ERC-7857 AgentINFT Contract

## Objective

Write `AgentINFT.sol` in `projects/contracts/src/` implementing ERC-721 with encrypted metadata storage, matching the ABI that the Go minter in `projects/agent-inference/internal/zerog/inft/minter.go` already encodes against.

## Requirements

- [ ] Contract inherits from OpenZeppelin's ERC721 and Ownable
- [ ] Contract exposes `mint(address to, string name, string description, bytes encryptedMetadata, bytes32 metadataHash, string daRef) returns (uint256)` — this is the exact signature the Go minter encodes
- [ ] Contract exposes `updateEncryptedMetadata(uint256 tokenId, bytes newEncryptedMetadata)` — restricted to token owner
- [ ] Contract emits a `Transfer` event on mint (standard ERC-721) so the Go minter can parse the token ID from the receipt

## Implementation

### Step 1: Read the Go minter ABI

In `projects/agent-inference/internal/zerog/inft/minter.go`, find the ABI string used for encoding. The minter packs calls to:

- `mint(address,string,string,bytes,bytes32,string)`
- `updateEncryptedMetadata(uint256,bytes)`

Your contract MUST match these signatures exactly.

### Step 2: Create the contract

Create `projects/contracts/src/AgentINFT.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AgentINFT is ERC721, Ownable {
    uint256 private _nextTokenId;

    struct TokenData {
        string name;
        string description;
        bytes encryptedMetadata;
        bytes32 metadataHash;
        string daRef;
    }

    mapping(uint256 => TokenData) private _tokenData;

    event MetadataUpdated(uint256 indexed tokenId, bytes32 newHash);

    constructor() ERC721("AgentINFT", "AINFT") Ownable(msg.sender) {}

    function mint(
        address to,
        string calldata name,
        string calldata description,
        bytes calldata encryptedMetadata,
        bytes32 metadataHash,
        string calldata daRef
    ) external returns (uint256) {
        uint256 tokenId = _nextTokenId++;
        _mint(to, tokenId);
        _tokenData[tokenId] = TokenData(name, description, encryptedMetadata, metadataHash, daRef);
        return tokenId;
    }

    function updateEncryptedMetadata(uint256 tokenId, bytes calldata newEncryptedMetadata) external {
        require(ownerOf(tokenId) == msg.sender, "not token owner");
        _tokenData[tokenId].encryptedMetadata = newEncryptedMetadata;
        _tokenData[tokenId].metadataHash = keccak256(newEncryptedMetadata);
        emit MetadataUpdated(tokenId, _tokenData[tokenId].metadataHash);
    }

    function getTokenData(uint256 tokenId) external view returns (TokenData memory) {
        require(ownerOf(tokenId) != address(0), "token does not exist");
        return _tokenData[tokenId];
    }
}
```

### Step 3: Install OpenZeppelin if needed

```bash
cd projects/contracts && forge install OpenZeppelin/openzeppelin-contracts --no-commit
```

Add the remapping to `foundry.toml` or `remappings.txt`:

```
@openzeppelin/=lib/openzeppelin-contracts/
```

### Step 4: Verify compilation

```bash
cd projects/contracts && forge build
```

## Done When

- [ ] All requirements met
- [ ] `forge build` succeeds with no errors and the ABI output matches the Go minter's expected function signatures