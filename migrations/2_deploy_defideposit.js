
require('dotenv').config();
const { ERC20_CONTRACT_ADDRESS } = process.env;

const DefiDeposit = artifacts.require("DefiDeposit");
module.exports = function (deployer) {
  deployer.deploy(DefiDeposit, ERC20_CONTRACT_ADDRESS);
}