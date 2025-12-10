// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";
import {Lockable} from "./utils/Lockable.sol";

contract PaymentToken is ERC20, Lockable, Pausable {
    string constant private _name = "test token for payment (payment token)";
    string constant private _symbol = "PAY";
    uint256 constant private _initialSupply = 100_000_000 * 1e18;

    /**
     * @notice Initializes the token with name/symbol and mints the initial supply to the owner.
     */
    constructor() ERC20(_name, _symbol) Ownable(msg.sender) {
        _mint(msg.sender, _initialSupply);
    }

    /**
     * @notice Pauses all token transfers, minting, and burning.
     * @dev Only callable by the owner. Uses OpenZeppelin Pausable.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @notice Unpauses token operations.
     * @dev Only callable by the owner.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /**
     * @notice Mints tokens to the owner account.
     * @param amount The amount of tokens to mint.
     * @dev Blocked while paused. Subject to lock rules only if owner is locked.
     */
    function mint(uint256 amount) external onlyOwner {
        _mint(owner(), amount);
    }

    /**
     * @notice Burns tokens from the owner account.
     * @param amount The amount of tokens to burn.
     * @dev Blocked while paused. Blocked if the owner is currently locked.
     */
    function burn(uint256 amount) external onlyOwner {
        _burn(owner(), amount);
    }

    /**
     * @dev Central accounting hook for all balance changes (transfer/mint/burn).
     * Applies pause checks and lock rules (spending address must be unlocked).
     * Always calls super to preserve ERC20 invariants.
     * @param from The source address (zero for mint).
     * @param to The destination address (zero for burn).
     * @param value The amount being moved.
     */
    function _update(address from, address to, uint256 value)
        internal
        override
        whenNotPaused
        whenUnlocked(from)
    {
        super._update(from, to, value);
    }
}


