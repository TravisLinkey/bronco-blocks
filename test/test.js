var bLottery = artifacts.require("./bLottery.sol");

contract('bLottery', function(accounts) {
    let bLotteryInstance


    it("should begin lottery", () => {
        return bLottery.new({
            from:accounts[0],
            gas: 4300000,
            gasPrice: 18
        })
        .then((instance) => {
            bLotteryInstance = instance;
            return instance.getBalance.call();
        })
        .then((balance) => {
            return web3.utils.fromWei(balance.toNumber().toString(), 'ether')
        })
        .then((balance) => {
            console.log("Lottery Started! ");
            assert.equal(balance.valueOf(), 0, 'lottery should not have any funds');
        })
    })

    it("account[1] should purchase 1 eth of tickets", () => {
        return web3.eth.getAccounts()
        .then((account) => {
            return bLotteryInstance.sellTickets({
                from: account[1],
                value: web3.utils.toWei('1', 'ether')
            })
        })
        .then(() => {
            return bLotteryInstance.getBalance.call();
        })
        .then((balance) => {
            assert.equal(
                web3.utils.fromWei(balance.toString(), 'ether'), 1, 'lottery should have 1 ether of tickets bought');
        })
        .then(() => {
            return bLotteryInstance.getOwnerBalance.call(accounts[1]);
        })
        .then((tickets) => {
            console.log(tickets.toNumber() + " tickets purchased! ");
            assert.notEqual(tickets.toNumber(), 0, 'lottery should have awarded tickets');
        })
    })

    // sleep thread
    var towait = 10000;
    setTimeout(function () {

        it("lottery should choose the user", () => {
                var winner = bLotteryInstance.selectWinner();
                console.log(winner + " gets paid!");
                assert.equal(winner, web3.eth.accounts[1], 'User was not paid');
            });

    }, towait);


})