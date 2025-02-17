const DefiDeposit = artifacts.require("DefiDeposit");
const ERC20Mock = artifacts.require("YidingCoin"); // 我们需要创建一个模拟的ERC20代币
const { BN, time, expectRevert } = require('@openzeppelin/test-helpers');
const { expect } = require('chai');

// 创建模拟的ERC20代币合约
contract("DefiDeposit", (accounts) => {
    const [owner, user1, user2] = accounts;
    let defiDeposit;
    let mockToken;
    const initialBalance = new BN('1000000000000000000000'); // 1000 tokens
    const depositAmount = new BN('100000000000000000000');   // 100 tokens

    beforeEach(async () => {
        // 部署模拟代币
        mockToken = await ERC20Mock.new("Mock Token", "MTK", owner, initialBalance);
        
        // 部署 DefiDeposit 合约
        defiDeposit = await DefiDeposit.new(mockToken.address);

        // 给测试用户转些代币
        await mockToken.transfer(user1, depositAmount, { from: owner });
    });

    describe("部署", () => {
        it("应该正确设置所有者", async () => {
            const contractOwner = await defiDeposit.owner();
            expect(contractOwner).to.equal(owner);
        });

        it("应该正确设置ERC20代币地址", async () => {
            const tokenAddress = await defiDeposit.ercToken();
            expect(tokenAddress).to.equal(mockToken.address);
        });
    });

    describe("ETH存款", () => {
        it("应该允许存入ETH", async () => {
            const depositValue = web3.utils.toWei('1', 'ether');
            await defiDeposit.deposit(depositValue, 0, { 
                from: user1, 
                value: depositValue 
            });

            const balance = await defiDeposit.getBalance(0, { from: user1 });
            expect(balance.toString()).to.equal(depositValue);
        });

        it("不应该允许存入0 ETH", async () => {
            await expectRevert(
                defiDeposit.deposit(0, 0, { from: user1, value: 0 }),
                "Amount should be greater than zero"
            );
        });
    });

    describe("ERC20存款", () => {
        beforeEach(async () => {
            // 授权 DefiDeposit 合约使用代币
            await mockToken.approve(defiDeposit.address, depositAmount, { from: user1 });
        });

        it("应该允许存入ERC20代币", async () => {
            await defiDeposit.deposit(depositAmount, 1, { from: user1 });
            const balance = await defiDeposit.getBalance(1, { from: user1 });
            expect(balance.toString()).to.equal(depositAmount.toString());
        });

        it("未授权时不应该允许存入ERC20代币", async () => {
            await expectRevert(
                defiDeposit.deposit(depositAmount, 1, { from: user2 }),
                "Transfer failed"
            );
        });
    });

    describe("利息计算", () => {
        it("应该正确计算ETH利息", async () => {
            const depositValue = web3.utils.toWei('1', 'ether');
            await defiDeposit.deposit(depositValue, 0, { 
                from: user1, 
                value: depositValue 
            });

            // 模拟时间流逝一年
            await time.increase(time.duration.years(1));

            const balance = await defiDeposit.getBalance(0, { from: user1 });
            const expectedBalance = new BN(depositValue).mul(new BN('105')).div(new BN('100'));
            expect(balance.toString()).to.equal(expectedBalance.toString());
        });

        it("应该正确计算ERC20代币利息", async () => {
            await mockToken.approve(defiDeposit.address, depositAmount, { from: user1 });
            await defiDeposit.deposit(depositAmount, 1, { from: user1 });

            // 模拟时间流逝一年
            await time.increase(time.duration.years(1));

            const balance = await defiDeposit.getBalance(1, { from: user1 });
            const expectedBalance = depositAmount.mul(new BN('105')).div(new BN('100'));
            expect(balance.toString()).to.equal(expectedBalance.toString());
        });
    });

    describe("提款", () => {
        it("应该允许提取ETH和利息", async () => {
            const depositValue = web3.utils.toWei('1', 'ether');
            await defiDeposit.deposit(depositValue, 0, { 
                from: user1, 
                value: depositValue 
            });

            await time.increase(time.duration.years(1));

            const initialBalance = new BN(await web3.eth.getBalance(user1));
            const tx = await defiDeposit.withdraw(depositValue, 0, { from: user1 });

            // 计算gas花费
            const gasUsed = new BN(tx.receipt.gasUsed);
            const gasPrice = new BN(await web3.eth.getGasPrice());
            const gasCost = gasUsed.mul(gasPrice);

            const finalBalance = new BN(await web3.eth.getBalance(user1));
            const balanceDiff = finalBalance.sub(initialBalance).add(gasCost);

            expect(balanceDiff.toString()).to.equal(depositValue);
        });

        it("应该允许提取ERC20代币和利息", async () => {
            await mockToken.approve(defiDeposit.address, depositAmount, { from: user1 });
            await defiDeposit.deposit(depositAmount, 1, { from: user1 });

            await time.increase(time.duration.years(1));

            const initialBalance = await mockToken.balanceOf(user1);
            await defiDeposit.withdraw(depositAmount, 1, { from: user1 });
            const finalBalance = await mockToken.balanceOf(user1);

            const balanceDiff = finalBalance.sub(initialBalance);
            expect(balanceDiff.toString()).to.equal(depositAmount.toString());
        });

        it("不应该允许提取超过余额的金额", async () => {
            const depositValue = web3.utils.toWei('1', 'ether');
            await defiDeposit.deposit(depositValue, 0, { 
                from: user1, 
                value: depositValue 
            });

            const withdrawAmount = web3.utils.toWei('2', 'ether');
            await expectRevert(
                defiDeposit.withdraw(withdrawAmount, 0, { from: user1 }),
                "Insufficient balance"
            );
        });
    });

    describe("合约余额查询", () => {
        it("所有者应该能查看合约ETH余额", async () => {
            const depositValue = web3.utils.toWei('1', 'ether');
            await defiDeposit.deposit(depositValue, 0, { 
                from: user1, 
                value: depositValue 
            });

            const contractBalance = await defiDeposit.getContractBalance(0, { from: owner });
            expect(contractBalance.toString()).to.equal(depositValue);
        });

        it("所有者应该能查看合约ERC20余额", async () => {
            await mockToken.approve(defiDeposit.address, depositAmount, { from: user1 });
            await defiDeposit.deposit(depositAmount, 1, { from: user1 });

            const contractBalance = await defiDeposit.getContractBalance(1, { from: owner });
            expect(contractBalance.toString()).to.equal(depositAmount.toString());
        });

        it("非所有者不应该能查看合约余额", async () => {
            await expectRevert(
                defiDeposit.getContractBalance(0, { from: user1 }),
                "Only owner can call this function"
            );
        });
    });
});