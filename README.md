# defi-deposit-contract

📌Solidity 作业：开发一个简单的 DeFi 存款合约

作业目标

你将编写一个 Solidity 智能合约，实现一个 简单的去中心化存款合约 (DeFi Deposit Contract)，允许用户：
 • 存入 ETH
 • 提取存款
 • 仅允许存入用户（owner）提取合约中对应的资金
 • 记录用户存款余额

作业要求
 1. 编写 Solidity 合约
 • 使用 Solidity 0.8.x 版本
 • 需要包含 deposit、withdraw 和 ownerWithdraw 方法
 • 记录每个用户的存款金额
 2. 实现功能
 • ✅允许用户存款
 • ✅允许用户取款
 • ✅仅限存入资金的人提取所有资金
 • ✅记录用户的存款余额
 3. 部署到测试网
 • 可选择 Remix + MetaMask 部署到 Goerli/ Sepolia 测试网(需通过水龙头领取测试代币)、部署到本地Ganache

💡进阶挑战
 1. 添加收益机制：比如，每次存款按时间计算利息，用户存得越久，利息越高。
 2. 添加代币存款功能：支持存入 ERC20 代币如Yideng币，而不仅仅是 ETH。
 3. 编写测试：使用 Hardhat 或 Truffle 进行单元测试，确保所有功能正常。
 4.  尽量前期先不借助AI 实在写不下去的地方可以借助AI

📌作业提交
 1.提交你的 测试网合约地址 + GitHub 代码链接。

