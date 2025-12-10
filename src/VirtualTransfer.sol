// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./SBTTransfer.sol";

/**
 * @title VirtualTransfer
 * @dev Wrapper contract that transfers PaymentToken and issues SBTTransfer (Proof of Transfer) atomically.
 */
contract VirtualTransfer {
    IERC20 public immutable paymentToken;
    SBTTransfer public immutable sbtTransfer;

    event TransferWithProof(address indexed sender, address indexed receiver, uint256 amount, string uri);

    /**
     * @dev Sets the PaymentToken and SBTTransfer contract addresses.
     */
    constructor(address _paymentToken, address _sbtTransfer) {
        require(_paymentToken != address(0), "Invalid PaymentToken address");
        require(_sbtTransfer != address(0), "Invalid SBTTransfer address");
        
        paymentToken = IERC20(_paymentToken);
        sbtTransfer = SBTTransfer(_sbtTransfer);
    }

    /**
     * @dev Transfers tokens and mints a proof-of-transfer SBT to the receiver.
     * @param receiver Address to receive the tokens and the SBT
     * @param amount Amount of PaymentToken to transfer
     * @param uri URI for the SBT metadata
     * 
     * Note: The caller must approve this contract (VirtualTransfer) to spend `amount` of PaymentToken beforehand.
     */
    function transferWithSBT(address receiver, uint256 amount, string memory uri) external {
        require(receiver != address(0), "Invalid receiver address");
        require(amount > 0, "Amount must be greater than 0");

        // 1. Transfer PaymentToken (Sender -> Receiver)
        // Requires allowance from msg.sender to this contract
        bool success = paymentToken.transferFrom(msg.sender, receiver, amount);
        require(success, "PaymentToken transfer failed");

        // 2. Issue SBTTransfer (To Receiver)
        // safeMint in SBTTransfer must be public or this contract must have MINTER role
        sbtTransfer.safeMint(receiver, uri);

        emit TransferWithProof(msg.sender, receiver, amount, uri);
    }
}

