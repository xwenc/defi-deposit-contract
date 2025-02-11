// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

contract YidingCoin is ERC20, Ownable, Pausable {
    // 代币参数
    uint256 public constant INITIAL_SUPPLY = 100_000_000 * 10**18; // 1亿代币
    uint256 public constant MAX_SUPPLY = 1_000_000_000 * 10**18;   // 10亿最大供应量
    
    // 铸币事件
    event TokensMinted(address indexed to, uint256 amount);
    
    // 销毁事件
    event TokensBurned(address indexed from, uint256 amount);
    
    constructor() ERC20("YidingCoin", "YDC") Ownable(msg.sender) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
    
    // 铸造新代币（只有所有者可以调用）
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalSupply() + amount <= MAX_SUPPLY, "Would exceed max supply");
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
    
    // 销毁代币
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
        emit TokensBurned(msg.sender, amount);
    }
    
    // 暂停所有转账（紧急情况使用）
    function pause() public onlyOwner {
        _pause();
    }
    
    // 恢复转账功能
    function unpause() public onlyOwner {
        _unpause();
    }
    
    // 重写转账相关函数，添加暂停检查
    function transfer(address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(to, amount);
    }
    
    function transferFrom(address from, address to, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transferFrom(from, to, amount);
    }
    
    // 批量转账功能
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public whenNotPaused {
        require(recipients.length == amounts.length, "Arrays must have same length");
        require(recipients.length > 0, "Arrays must not be empty");
        
        for(uint i = 0; i < recipients.length; i++) {
            require(transfer(recipients[i], amounts[i]), "Transfer failed");
        }
    }
    
    // 查看账户代币余额
    function balanceOfAccount(address account) public view returns (uint256) {
        return balanceOf(account);
    }
    
    // 查看总供应量
    function getTotalSupply() public view returns (uint256) {
        return totalSupply();
    }
    
    // 查看剩余可铸造数量
    function getRemainingMintableSupply() public view returns (uint256) {
        return MAX_SUPPLY - totalSupply();
    }
}