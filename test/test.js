const Benefit = artifacts.require("Benefit");
const TestToken = artifacts.require("TestToken");
const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');
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
    it("false on account 2", async () => {
        let instance = await Benefit.deployed();
        let status = await instance.IsPOZHolder(accounts[2]);
        assert.isFalse(status);
    });
    it("false on account 3", async () => {
        let instance = await Benefit.deployed();
        let status = await instance.IsPOZHolder(accounts[3]);
        assert.isFalse(status);
    });
    it("set SetMinHold ", async () => {
        let instance = await Benefit.deployed();
        await instance.SetMinHold(15, { from: accounts[0] });
        let hold = await instance.MinHold.call();
        assert.equal(hold.toNumber(), 15);
    });
    it("Can't Remove when none ", async () => {
        let instance = await Benefit.deployed();
        await truffleAssert.reverts(instance.RemoveLastBalanceCheckData({ from: accounts[0] }));
    });
    it("Add Token", async () => {
        let instance = await Benefit.deployed();
        let token = await TestToken.deployed();
        await instance.AddNewToken(token.address, { from: accounts[0] });
        assert.equal(await instance.ChecksCount.call(), 1,"Got only 1");
        assert.isFalse(await instance.IsPOZHolder(accounts[5]),"No token - No benefit");
        await token.FreeTest({ from: accounts[5] });
        assert.isTrue(await instance.IsPOZHolder(accounts[5]),"Got toke = Got benefit");
        //console.log((await instance.CalcTotal(accounts[5])).toNumber());
    });
    it("Remove Token - get false ", async () => {
        let instance = await Benefit.deployed();
        await instance.RemoveLastBalanceCheckData({ from: accounts[0] });
        assert.isFalse(await instance.IsPOZHolder(accounts[5]),"No token - No benefit");
    });
});