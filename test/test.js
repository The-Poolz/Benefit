const Benefit = artifacts.require("Benefit");
const TestToken = artifacts.require("TestToken");
const { assert } = require('chai');
//const truffleAssert = require('truffle-assertions');
//const timeMachine = require('ganache-time-traveler');
const zero_address = "0x0000000000000000000000000000000000000000";
//var BN = web3.utils.BN;

//const rate = new BN('1000000000'); // with decimal21 (shifter) 1 eth^18 = 1 token^6
//const amount = new BN('3000000'); //3 tokens for sale
//const invest = web3.utils.toWei('1', 'ether'); //1eth;

contract("Benefit", async accounts => {
    it("return false after deploy", async () => {
        let instance = await Benefit.deployed();
        let status = await instance.IsPOZHolder(accounts[5]);
        assert.isFalse(status);
    });
    it("base start address", async () => {
        let instance = await Benefit.deployed();
        let tokenAdress = await instance.TokenAddress.call();
        assert.equal(tokenAdress, zero_address);
    });
    it("set token address address", async () => {
        let instance = await Benefit.deployed();
        let token = await TestToken.deployed();
        await instance.SetTokenAddress(token.address, { from: accounts[0] });
        let tokenAdress = await instance.TokenAddress.call();
        assert.equal(tokenAdress, token.address);
    });
    it("false on account 2", async () => {
        let instance = await Benefit.deployed();
        let status = await instance.IsPOZHolder(accounts[2]);
        assert.isFalse(status);
    });
    it("true after transfer", async () => {
        let instance = await Benefit.deployed();
        let token = await TestToken.deployed();
        token.transfer(accounts[2],1, { from: accounts[0] });
        let status = await instance.IsPOZHolder(accounts[2]);
        assert.isTrue(status);
    });
    it("false on account 3", async () => {
        let instance = await Benefit.deployed();
        let status = await instance.IsPOZHolder(accounts[3]);
        assert.isFalse(status);
    });
    it("true after freetest", async () => {
        let instance = await Benefit.deployed();
        let token = await TestToken.deployed();
        token.FreeTest({ from: accounts[3] });
        let status = await instance.IsPOZHolder(accounts[3]);
        assert.isTrue(status);
    });
    it("Next in line", async () => {
        let instance = await Benefit.deployed();
        let instance2 = await Benefit.new();
        let token2 = await TestToken.new();
        await instance.SetPOZBenefitAddress(instance2.address, {from:accounts[0] })
        await instance2.SetTokenAddress(token2.address, { from: accounts[0] });
        let status = await instance.IsPOZHolder(accounts[5]);
        assert.isFalse(status);
        await token2.FreeTest({from: accounts[5]});
        status = await instance.IsPOZHolder(accounts[5]);
        assert.isTrue(status);
    });

});