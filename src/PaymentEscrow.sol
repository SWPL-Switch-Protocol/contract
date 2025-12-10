// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PaymentEscrow.sol
 * @dev A simple escrow contract where buyers deposit funds, and funds are released to the seller upon confirmation.
 *      The arbiter (Owner) can intervene in case of disputes.
 */
contract PaymentEscrow is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    enum State { Created, Released, Refunded }

    struct Order {
        address buyer;
        address seller;
        uint256 amount;
        State state;
    }

    // Order ID => Order Info
    mapping(uint256 => Order) public orders;

    event Deposited(uint256 indexed orderId, address indexed buyer, address indexed seller, uint256 amount);
    event Released(uint256 indexed orderId, address indexed seller, uint256 amount);
    event Refunded(uint256 indexed orderId, address indexed buyer, uint256 amount);
    event DisputeResolved(uint256 indexed orderId, address indexed winner, uint256 amount);

    /**
     * @dev Sets the ERC20 token address and the arbiter address.
     */
    constructor(address _token) Ownable(msg.sender) {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
    }

    /**
     * @dev Deposits funds into the escrow. (Requires prior approval)
     * @param orderId Order identifier (must be unique)
     * @param seller Seller address
     * @param amount Amount to deposit
     */
    function deposit(uint256 orderId, address seller, uint256 amount) external {
        require(seller != address(0), "Invalid seller address");
        require(amount > 0, "Amount must be greater than 0");
        require(orders[orderId].amount == 0, "Order ID already exists");

        // Store state
        orders[orderId] = Order({
            buyer: msg.sender,
            seller: seller,
            amount: amount,
            state: State.Created
        });

        // Transfer tokens (Buyer -> Escrow)
        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(orderId, msg.sender, seller, amount);
    }

    /**
     * @dev Releases funds to the seller upon buyer confirmation.
     * @param orderId Order identifier
     */
    function release(uint256 orderId) external {
        Order storage order = orders[orderId];
        
        require(msg.sender == order.buyer, "Only buyer can release");
        require(order.state == State.Created, "Invalid order state");

        order.state = State.Released;

        // Transfer tokens (Escrow -> Seller)
        token.safeTransfer(order.seller, order.amount);

        emit Released(orderId, order.seller, order.amount);
    }

    /**
     * @dev Refunds funds to the buyer upon seller cancellation.
     * @param orderId Order identifier
     */
    function refund(uint256 orderId) external {
        Order storage order = orders[orderId];

        require(msg.sender == order.seller, "Only seller can refund");
        require(order.state == State.Created, "Invalid order state");

        order.state = State.Refunded;

        // Transfer tokens (Escrow -> Buyer)
        token.safeTransfer(order.buyer, order.amount);

        emit Refunded(orderId, order.buyer, order.amount);
    }
    
    /**
     * @dev Resolves a dispute by transferring funds to the receiver. Only the owner (arbiter) can call this.
     * @param orderId Order identifier
     * @param receiver Address to receive the funds (Must be Buyer or Seller)
     */
    function resolveDispute(uint256 orderId, address receiver) external onlyOwner {
        Order storage order = orders[orderId];
        require(order.state == State.Created, "Invalid order state");
        require(receiver == order.buyer || receiver == order.seller, "Winner must be buyer or seller");

        if (receiver == order.seller) {
            order.state = State.Released;
            token.safeTransfer(order.seller, order.amount);
            emit Released(orderId, order.seller, order.amount);
        } else {
            order.state = State.Refunded;
            token.safeTransfer(order.buyer, order.amount);
            emit Refunded(orderId, order.buyer, order.amount);
        }
        
        emit DisputeResolved(orderId, receiver, order.amount);
    }
    
    /**
     * @dev Returns the order details.
     */
    function getOrder(uint256 orderId) external view returns (Order memory) {
        return orders[orderId];
    }
}

