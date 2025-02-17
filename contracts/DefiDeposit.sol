// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
  * @title DefiDeposit
  * @dev A contract for depositing and withdrawing funds with interest
 */

contract DefiDeposit {
    using SafeERC20 for IERC20;

    address public owner;
    address public ercToken;

    uint256 public INTEREST_RATE = 500; // 5% annual interest rate
    uint256 public SECONDS_ANNUAL = 31536000;

    struct Deposit {
        uint256 amount;
        uint256 timestamp;
        uint256 lastInterestCalculation;
    }

    enum TokenTypes {
        ETH,
        ERC20
    }

    mapping(TokenTypes => mapping(address => Deposit)) public deposits;

    constructor(address _ercToken) {
        owner = msg.sender;
        ercToken = _ercToken;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier amountGreaterThanZero(uint256 _amount) {
        require(_amount > 0, "Amount should be greater than zero");
        _;
    }

    event Deposited(
        address indexed user,
        uint256 amount,
        TokenTypes tokenTypes
    );
    event Withdrawn(
        address indexed user,
        uint256 amount,
        TokenTypes tokenTypes
    );

    /**
      * @dev Deposit funds
      * @param _amount Amount to deposit
      * @param _tokenTypes Token type
     */
    function deposit(
        uint256 _amount,
        TokenTypes _tokenTypes
    ) public payable amountGreaterThanZero(_amount) {
        if (_tokenTypes == TokenTypes.ETH) {
            deposits[TokenTypes.ETH][msg.sender].amount += msg.value;
        } else if (_tokenTypes == TokenTypes.ERC20) {
            require(
                IERC20(ercToken).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Transfer failed"
            );
            deposits[TokenTypes.ERC20][msg.sender].amount += _amount;
        }
        deposits[_tokenTypes][msg.sender].timestamp = block.timestamp;
        deposits[_tokenTypes][msg.sender].lastInterestCalculation = block
            .timestamp;
        emit Deposited(msg.sender, _amount, _tokenTypes);
    }

    /**
      * @dev Withdraw funds
      * @param _amount Amount to withdraw
      * @param _tokenTypes Token type
     */
    function withdraw(
        uint256 _amount,
        TokenTypes _tokenTypes
    ) public amountGreaterThanZero(_amount) {
        uint interest = _getInterest(_tokenTypes);
        uint totalAmount = deposits[_tokenTypes][msg.sender].amount + interest;
        require(
            totalAmount >= _amount,
            "Insufficient balance"
        );
        if (_tokenTypes == TokenTypes.ETH) {
            payable(msg.sender).transfer(_amount);
            deposits[TokenTypes.ETH][msg.sender].amount = totalAmount - _amount;
        } else if (_tokenTypes == TokenTypes.ERC20) {
            IERC20(ercToken).safeTransfer(msg.sender, _amount);
            deposits[TokenTypes.ERC20][msg.sender].amount = totalAmount - _amount;
        }
        deposits[_tokenTypes][msg.sender].lastInterestCalculation = block.timestamp;
        emit Withdrawn(msg.sender, _amount, _tokenTypes);
    }

    /**
      * @dev Get interest
      * @param _tokenTypes Token type
      * @return Interest
     */
    function _getInterest(
        TokenTypes _tokenTypes
    ) private view returns (uint256) {
        Deposit memory userDeposit = deposits[_tokenTypes][msg.sender];
        uint256 timeElapsed = block.timestamp - userDeposit.lastInterestCalculation;

        // 使用基点计算利息：本金 * 年化利率 * 时间占比
        uint256 interest = userDeposit.amount * INTEREST_RATE * timeElapsed / SECONDS_ANNUAL / 10000;

        return interest;
    }

    /**
      * @dev Get user balance
      * @param _tokenTypes Token type
      * @return User balance
     */
    function getBalance(TokenTypes _tokenTypes) public view returns (uint256) {
        return deposits[_tokenTypes][msg.sender].amount + _getInterest(_tokenTypes);
    }


    /**
      * @dev Get contract balance
      * @param _tokenTypes Token type
      * @return Contract balance
     */
    function getContractBalance(
        TokenTypes _tokenTypes
    ) public view onlyOwner returns (uint256) {
        if (_tokenTypes == TokenTypes.ETH) {
            return address(this).balance;
        } else if (_tokenTypes == TokenTypes.ERC20) {
            return IERC20(ercToken).balanceOf(address(this));
        } else {
            return 0;
        }
    }
}
