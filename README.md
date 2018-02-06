# Money Token ICO Contract

Please see below description of [MoneyToken ICO][moneytoken] smart contract developed by [Phenom.Team][phenom].


## Overview
IMT Token smart-contract is structured upon [ERC20 standard](erc20). 
Ethereum is not the only currency investors can use when investing, they can also opt to purchase IMT tokens with BTC, LTC, BCC. Selling tokens will be done through a personal account. For each investor will be allocated an individual BTC, BCH, LTC, ETH address, which will track all transactions. IMT tokens will be deposited in accordance with the virtual balances after the end of crowsale.

## The Crowdsale Specification
*	IMT token is ERC-20 compliant.
*   Allocation of IMT tokens goes in the following way:
	* Bounty 1%
	* Advisors 2%
	* Bancor 2%
	* Team 10%
	* Reserve fund 40%
	* Public ICO 45%

  
## Code

#### MoneyTokenICO Functions

**startEmission**
```cs
function startEmission() external managerOnly
```
Set ICO status to Started.

**finishEmission**
```cs
function finishEmission() external managerOnly
```
Set Ico status to Finished and issue tokens for funds.


**buyForInvestor**
```cs
function buyForInvestor( address _investor, uint _imtValue, uint _bonusPart) external controllersOnly

```
buyForInvestor function is called by one of controllers to issue tokens for investors.



#### MoneyTokenICO Events

**LogStartEmission**
```cs
event LogStartEmission();
```
**LogFinishEmission**
```cs
event LogFinishEmission();
```

**LogBuyForInvestor**
```cs
event LogBuyForInvestor(address investor, uint imtValue);
```

## Prerequisites
1. nodejs, and make sure it's version above 8.0.0
2. npm
3. truffle
4. testrpc

## Run tests
1. run `testrpc -a 11` in terminal
2. run `truffle test` in another terminal to execute tests.


## Collaborators

* **[Alex Smirnov](https://github.com/AlekseiSmirnov)**
* **[Max Petriev](https://github.com/maxpetriev)**
* **[Dmitriy Pukhov](https://github.com/puhoshville)**
* **[Kate Krishtopa](https://github.com/Krishtopa)**

[moneytoken]: https://moneytoken.com/
[phenom]: https://phenom.team/
[erc20]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md