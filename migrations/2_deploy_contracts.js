var MoneyTokenICO = artifacts.require("MoneyTokenICO.sol");
//var config = require("./config.json");


module.exports = function(deployer, network, accounts) {
    deployer.deploy(
    MoneyTokenICO,
    accounts[0],
    accounts[1],
    accounts[2],
    accounts[3],
    accounts[4],
    accounts[5],
    accounts[6],
    accounts[6],
    accounts[6]
        );


/*
    deployer.deploy(
    MoneyTokenICO,
    config.ReserveFund,
    config.TeamFund,
    config.AdvisorsFund,
    config.BancorFund,
    config.BountyFund,
    config.Manager,
    config.Controller_Address1,
    config.Controller_Address2,
    config.Controller_Address3
        );


*/

};

