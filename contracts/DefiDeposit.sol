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

    address private owner;
    address private ercToken;

    uint private INTEREST_RATE = 500; // 5% annual interest rate
    uint private SECONDS_ANNUAL = 31536000;
    address private constant ETH_ADDRESS = address(0);

    struct Deposit {
        uint amount;
        uint timestamp;
        uint lastInterestCalculation;
    }

    mapping(address => mapping(address => Deposit)) private deposits;

    constructor(address _ercToken) {
        owner = msg.sender;
        ercToken = _ercToken;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier amountGreaterThanZero(uint _amount) {
        require(_amount > 0, "Amount should be greater than zero");
        _;
    }

    event Deposited(address indexed user, uint amount, address token);
    event Withdrawn(address indexed user, uint amount, address token);

    /**
     * @dev Deposit ETH
     */
    function ethDeposit() public payable {
        _deposit(msg.value, ETH_ADDRESS);
    }

    /**
     * @dev Deposit ERC20 token
     */
    function erc20Deposit(uint _amount) public amountGreaterThanZero(_amount) {
        IERC20(ercToken).safeTransferFrom(msg.sender, address(this), _amount);
        _deposit(_amount, ercToken);
    }

    /**
     * @dev Deposit funds
     * @param _amount Amount to deposit
     * @param _token Token address
     */
    function _deposit(
        uint _amount,
        address _token
    ) private amountGreaterThanZero(_amount) {
        Deposit storage userDeposit = deposits[_token][msg.sender];
        userDeposit.amount += _amount;
        userDeposit.timestamp = block.timestamp;
        userDeposit.lastInterestCalculation = block.timestamp;
        emit Deposited(msg.sender, _amount, _token);
    }

    /**
     * @dev Withdraw ETH
     */
    function ethWithdraw(uint _amount) public amountGreaterThanZero(_amount) {
        payable(msg.sender).transfer(_amount);
        _withdraw(_amount, ETH_ADDRESS);
    }

    /**
     * @dev Withdraw ERC20 token
     */
    function erc20Withdraw(uint _amount) public amountGreaterThanZero(_amount) {
        IERC20(ercToken).safeTransfer(msg.sender, _amount);
        _withdraw(_amount, ercToken);
    }

    /**
     * @dev Withdraw funds
     * @param _amount Amount to withdraw
     * @param _token Token address
     */
    function _withdraw(
        uint _amount,
        address _token
    ) private amountGreaterThanZero(_amount) {
        uint interest = _getInterest(_token);
        Deposit storage userDeposit = deposits[_token][msg.sender];
        uint totalAmount = userDeposit.amount + interest;
        require(totalAmount >= _amount, "Insufficient balance");
        userDeposit.amount = totalAmount - _amount;
        userDeposit.lastInterestCalculation = block.timestamp;
        emit Withdrawn(msg.sender, _amount, _token);
    }

    /**
     * @dev Get interest
     * @param _token Token address
     * @return Interest
     */
    function _getInterest(address _token) private view returns (uint) {
        Deposit memory userDeposit = deposits[_token][msg.sender];
        uint timeElapsed = block.timestamp -
            userDeposit.lastInterestCalculation;

        // 使用基点计算利息：本金 * 年化利率 * 时间占比
        uint interest = (userDeposit.amount * INTEREST_RATE * timeElapsed) /
            SECONDS_ANNUAL /
            10000;

        return interest;
    }

    /**
     * @dev Get ETH balance
     */
    function ethBalance() public view returns (uint) {
        return _getBalance(ETH_ADDRESS);
    }

    /**
     * @dev Get ERC20 balance
     */
    function erc20Balance() public view returns (uint) {
        return _getBalance(ercToken);
    }

    /**
     * @dev Get user balance
     * @param _token Token
     * @return User balance
     */
    function _getBalance(address _token) private view returns (uint) {
        return deposits[_token][msg.sender].amount + _getInterest(_token);
    }

    /**
     * @dev Get contract balance
     * @param _token Token
     * @return Contract balance
     */
    function getContractBalance(
        address _token
    ) public view onlyOwner returns (uint) {
        if (_token == ETH_ADDRESS) {
            return address(this).balance;
        } else if (_token == ercToken) {
            return IERC20(ercToken).balanceOf(address(this));
        } else {
            return 0;
        }
    }

    receive() external payable {
        revert("Use deposit() to deposit ETH");
    }

    fallback() external payable {
        revert("Function does not exist");
    }
}
