// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title PaymentEscrow.sol
 * @dev 구매자가 자금을 맡기고, 구매 확정 시 판매자에게 전달하는 간단한 에스크로 컨트랙트입니다.
 */
contract PaymentEscrow {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;

    enum State { Created, Released, Refunded }

    struct Order {
        address buyer;
        address seller;
        uint256 amount;
        State state;
    }

    // 주문 ID => 주문 정보
    mapping(uint256 => Order) public orders;

    event Deposited(uint256 indexed orderId, address indexed buyer, address indexed seller, uint256 amount);
    event Released(uint256 indexed orderId, address indexed seller, uint256 amount);
    event Refunded(uint256 indexed orderId, address indexed buyer, uint256 amount);

    /**
     * @dev 에스크로에서 사용할 ERC20 토큰 주소를 설정합니다.
     */
    constructor(address _token) {
        require(_token != address(0), "Invalid token address");
        token = IERC20(_token);
    }

    /**
     * @dev 구매자가 자금을 예치합니다. (사전에 approve 필요)
     * @param orderId 주문 식별자 (중복 불가)
     * @param seller 판매자 주소
     * @param amount 예치할 금액
     */
    function deposit(uint256 orderId, address seller, uint256 amount) external {
        require(seller != address(0), "Invalid seller address");
        require(amount > 0, "Amount must be greater than 0");
        require(orders[orderId].amount == 0, "Order ID already exists");

        // 상태 저장
        orders[orderId] = Order({
            buyer: msg.sender,
            seller: seller,
            amount: amount,
            state: State.Created
        });

        // 토큰 전송 (Buyer -> Escrow)
        token.safeTransferFrom(msg.sender, address(this), amount);

        emit Deposited(orderId, msg.sender, seller, amount);
    }

    /**
     * @dev 구매자가 물품 수령을 확인하고 대금을 판매자에게 지급합니다.
     * @param orderId 주문 식별자
     */
    function release(uint256 orderId) external {
        Order storage order = orders[orderId];
        
        require(msg.sender == order.buyer, "Only buyer can release");
        require(order.state == State.Created, "Invalid order state");

        order.state = State.Released;

        // 토큰 전송 (Escrow -> Seller)
        token.safeTransfer(order.seller, order.amount);

        emit Released(orderId, order.seller, order.amount);
    }

    /**
     * @dev 판매자가 거래를 취소하고 대금을 구매자에게 환불합니다.
     * @param orderId 주문 식별자
     */
    function refund(uint256 orderId) external {
        Order storage order = orders[orderId];

        require(msg.sender == order.seller, "Only seller can refund");
        require(order.state == State.Created, "Invalid order state");

        order.state = State.Refunded;

        // 토큰 전송 (Escrow -> Buyer)
        token.safeTransfer(order.buyer, order.amount);

        emit Refunded(orderId, order.buyer, order.amount);
    }
    
    /**
     * @dev 주문 정보를 조회합니다.
     */
    function getOrder(uint256 orderId) external view returns (Order memory) {
        return orders[orderId];
    }
}

