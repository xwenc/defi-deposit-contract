# 💰 DeFi 存款智能合约 (DeFi Deposit Contract)

本作业要求编写一个 Solidity 智能合约，实现一个 **去中心化存款合约**，允许用户存入和提取 ETH，同时确保存款安全性和归属权。

---

## 📌 作业目标

你需要编写一个 Solidity 合约，实现以下核心功能：
- ✅ **存入 ETH**
- ✅ **提取存款**
- ✅ **仅允许存入用户（owner）提取对应的资金**
- ✅ **记录用户存款余额**

---

## 📌 作业要求

### 1️⃣ 编写 Solidity 合约
- 使用 **Solidity 0.8.x** 版本
- 需要包含以下核心方法：
  - `deposit()` → 允许用户存款
  - `withdraw(uint amount)` → 允许用户提取存款
  - `ownerWithdraw()` → 仅限存入资金的人提取所有资金
- 记录每个用户的存款余额

### 2️⃣ 实现功能
- ✅ **允许用户存款**
- ✅ **允许用户取款**
- ✅ **仅限存入资金的人提取所有资金**
- ✅ **记录用户的存款余额**

### 3️⃣ 部署到测试网
- 可选择 **Remix + MetaMask** 部署到 **Goerli** 或 **Sepolia** 测试网
- 也可部署到 **本地 Ganache**
- 领取测试代币（ETH）进行测试

---

## 💡 进阶挑战

> 你可以尝试实现更高级的 DeFi 功能，让合约更加实用 🚀

1. **添加收益机制**：
   - 存款按时间计算利息，用户存得越久，利息越高。
2. **添加代币存款功能**：
   - 支持存入 **ERC-20 代币**（如自定义的 Yideng 币）。
3. **编写单元测试**：
   - 使用 **Hardhat** 或 **Truffle** 进行测试，确保所有功能正常运行。
4. **尽量自己独立编写**，实在遇到困难再借助 AI 解决问题。

---

## 📌 作业提交

- 提交你的 **测试网合约地址**
- 提交你的 **GitHub 代码仓库链接**

---

🔥 **加油！让我们一起构建一个安全可靠的 DeFi 存款合约！** 🚀



# Truffle 项目部署步骤

## 1. 安装 Truffle
```bash
npm install -g truffle
```

## 2. 初始化项目
```bash
truffle init
```

## 3. 编写合约
在 `contracts/DefiDeposit.sol` 文件中编写合约代码。

## 4. 编写部署脚本
在 `migrations/2_deploy_contracts.js` 文件中编写合约部署脚本。

## 5. 编写测试
在 `test/DefiDeposit.test.js` 文件中编写合约的测试代码。

## 6. 本地部署
```bash
truffle migrate --reset
```

## 7. 测试网部署
```bash
truffle migrate --network sepolia --reset
```

## 8. 交互测试
```bash
truffle console --network sepolia
```
