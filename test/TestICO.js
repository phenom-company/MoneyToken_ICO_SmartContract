var MoneyTokenICO = artifacts.require("MoneyTokenICO.sol");
var ImtToken = artifacts.require("ImtToken.sol");

contract('MoneyTokenICO', function(accounts) {
    function randomInteger(min, max) {
        var rand = min - 0.5 + Math.random() * (max - min + 1)
        rand = Math.round(rand);
        return rand;
    };
    var ImtTokenContract; 
    var MoneyTokenIcoContract;
    // Outside addresses
    var ReserveFund = accounts[0];
    var TeamFund = accounts[1];
    var AdvisorsFund = accounts[2];
    var BancorFund = accounts[3];
    var BountyFund = accounts[4];
    var Manager = accounts[5];
    var Controller_Address1 = accounts[6];
    var Controller_Address2 = accounts[6];
    var Controller_Address3 = accounts[6];
    var notManager = accounts[7];
    var notController = accounts[8];
    // Investors addresses
    var firstInvestor = accounts[9];
    var secondInvestor = accounts[10];


/* 
====================================================================================================
Start of testing
====================================================================================================
*/    
    it('shouldn\'t issue tokens when ico status is created', function() {
        return MoneyTokenICO.deployed()
        .then(function(instance) {
            MoneyTokenIcoContract = instance;
            var tokens = randomInteger(100000, 10000000);
            var bonus = 10; 
            return MoneyTokenIcoContract.buyForInvestor(
                firstInvestor,
                tokens,
                bonus,
                {
                    from: Controller_Address1
                }
            );
        })
        .then(function() {
            assert(false, 'token were minted');
        })
        .catch(function(e) {
        });
    });

    it('shouldn\'t allow to start emission for someone except manager', function () {
        return MoneyTokenIcoContract.startEmission({
            from: notManager
            }
        )
        .then(function(tx) {
            assert(false, 'emission was started from not manager');
        })
        .catch(function(e) {
        });
    });

    it('should start emission', function () {
        return MoneyTokenIcoContract.startEmission({
            from: Manager
            }
        )
        .catch(function(e) {
            assert(false, 'emission was not started');
        })
    });

    it('shouldn\'t allow to issue tokens for someone except controllers', function() {
        var tokens = randomInteger(100000, 10000000);
        var bonus = 10; 
        return MoneyTokenIcoContract.buyForInvestor(
            firstInvestor,
            tokens,
            bonus,
            {
                from: notController
            }
        )
        .then(function() {
            assert(false, 'tokens were minted');
        })
        .catch(function(e) {
        });
    });
       
    it('should issue tokens', async function() {
        var tokenAddress = await MoneyTokenIcoContract.IMT.call();
        ImtTokenContract = ImtToken.at(tokenAddress);
        var tokens = randomInteger(100000, 10000000);
        var bonus = 10; 
        await MoneyTokenIcoContract.buyForInvestor(
            firstInvestor,
            tokens,
            bonus,
            {
                from: Controller_Address1
            }
        );
        var balance = await ImtTokenContract.balanceOf.call(firstInvestor);
        var correctBalance = tokens + Math.floor(tokens * bonus / 100);
        assert.equal(parseInt(balance.toString()), correctBalance, 'tokens weren\'t minted correctly');
    });        


    it('shouldn\'t allow tokens transfers when ico status is started', function() {
        var tokensToTransfer = randomInteger(1, 10000);
        return ImtTokenContract.transfer(
                secondInvestor,
                tokensToTransfer, 
                {
                    from: firstInvestor
                }
        )
        .then(function() {
            assert(false, 'tokens were transfered');
        })
        .catch(function(e) {
        });
    });

    it('shouldn\'t allow to exceed HardCap', function() {
        var tokens = parseFloat(10120000000 + 'E18');
        return MoneyTokenIcoContract.buyForInvestor(
            secondInvestor,
            tokens,
            0,
            {
                from: Controller_Address1
            }
        )
        .then(function() {
            assert(false, 'HardCap was exceeded');
        })
        .catch(function(e) {
        })        
    });

    it('shouldn\'t allow to finish emission for someone except manager', function () {
        return MoneyTokenIcoContract.finishEmission({
            from: notManager
            }
        )
        .then(function(tx) {
            assert(false, 'emission was finished from not manager');
        })
        .catch(function(e) {
        });
    });

    it('should finish emission', function () {
        return MoneyTokenIcoContract.finishEmission({
            from: Manager
            }
        )
        .catch(function(tx) {
            assert(false, 'ico was not finished');
        })
    });

    it('should check validity of tokens distribution', async function() {
        var totalSupply = await ImtTokenContract.totalSupply.call();
        var reservePart = await ImtTokenContract.balanceOf.call(ReserveFund);
        var teamPart = await ImtTokenContract.balanceOf.call(TeamFund);
        var advisorsPart = await ImtTokenContract.balanceOf.call(AdvisorsFund);
        var bancorPart = await ImtTokenContract.balanceOf.call(BancorFund);
        var bountyPart = await ImtTokenContract.balanceOf.call(BountyFund);
        assert.equal(
            Math.round((reservePart.toNumber()/ totalSupply.toNumber()) * 100) / 100, 
            0.4,
            'reserve part is not correct'
        );  
        assert.equal(
            Math.round((teamPart.toNumber()/ totalSupply.toNumber()) * 100) / 100, 
            0.1,
            'team part is not correct'
        );
        assert.equal(
            Math.round((advisorsPart.toNumber()/ totalSupply.toNumber()) * 100) / 100, 
            0.02,
            'advisors part is not correct'
        );
        assert.equal(
            Math.round((bancorPart.toNumber()/ totalSupply.toNumber()) * 100) / 100, 
            0.02,
            'bancor part is not correct'
        );
        assert.equal(
            Math.round((bountyPart.toNumber()/ totalSupply.toNumber()) * 100) / 100, 
            0.01, 
            'bounty part is not correct'
        );
    });


    it('shouldn\'t allow to start emission after emission was finished', function () {
        return MoneyTokenIcoContract.startEmission({
            from: Manager
            }
        )
        .then(function(tx) {
            assert(false, 'ico was started');
        })
        .catch(function(e) {
        });
    });

    it('shouldn\'t issue tokens when ico status is finished', function() {
        return MoneyTokenICO.deployed()
        .then(function(instance) {
            MoneyTokenIcoContract = instance;
            var tokens = randomInteger(100000, 10000000);
            var bonus = 10; 
            return MoneyTokenIcoContract.buyForInvestor(
                firstInvestor,
                tokens,
                bonus,
                {
                    from: Controller_Address1
                }
            );
        })
        .then(function() {
            assert(false, 'tokens were minted');
        })
        .catch(function(e) {
        });
    });

    it('should allow tokens transfers when iso status is finished', function() {
        var tokensToTransfer = randomInteger(1, 10000);
        return ImtTokenContract.transfer(
                secondInvestor,
                tokensToTransfer, 
                {
                    from: firstInvestor
                }
        )
        .then(function() {
            return ImtTokenContract.balanceOf.call(secondInvestor);
        })
        .then(function(balance) {
            assert.equal(balance.toNumber(), tokensToTransfer, 'tokens were not transfered')
        })
    });
});
