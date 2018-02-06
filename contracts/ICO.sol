// MoneyToken tokensale smart contract.
// Developed by Phenom.Team <info@phenom.team>
pragma solidity ^0.4.15;

/**
 *   @title SafeMath
 *   @dev Math operations with safety checks that throw on error
 */

library SafeMath {

  function mul(uint a, uint b) internal constant returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal constant returns(uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function sub(uint a, uint b) internal constant returns(uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal constant returns(uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 *   @title ERC20
 *   @dev Standart ERC20 token interface
 */

contract ERC20 {
    uint public totalSupply = 0;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    function balanceOf(address _owner) constant returns (uint);
    function transfer(address _to, uint _value) returns (bool);
    function transferFrom(address _from, address _to, uint _value) returns (bool);
    function approve(address _spender, uint _value) returns (bool);
    function allowance(address _owner, address _spender) constant returns (uint);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);

} 

/**
 *   @title MoneyTokenICO contract  - takes funds from users and issues tokens
 */
contract MoneyTokenICO {
    // IMT - Level Up Coin token contract
    using SafeMath for uint;
    ImtToken public IMT = new ImtToken(this);

    //Crowdsale parameters
    uint constant publicIcoPart = 45; // 45% of TotalSupply for publicICO 
    uint constant reservePart = 40;// 40% of TotalSupply for ReserveFund
    uint constant teamPart = 10; // 10% of TotalSupply for TeamFund
    uint constant advisorsPart = 2; // 2% of TotalSupply for AdvisorsFund 
    uint constant bancorPart = 2; // 2% of TotalSupply for BancorFund
    uint constant bountyPart = 1; // 1% of TotalSupply for BountyFund
    uint constant hardCap = 10120000000*1e18; 
    uint public soldAmount = 0;
    // Output ethereum addresses
    address public ReserveFund;
    address public TeamFund;
    address public AdvisorsFund;
    address public BancorFund;
    address public BountyFund;
    address public Manager; // Manager controls contract
    address public Controller_Address1; // First address that is used to buy tokens for other cryptos
    address public Controller_Address2; // Second address that is used to buy tokens for other cryptos
    address public Controller_Address3; // Third address that is used to buy tokens for other cryptos

    // Possible ICO statuses
    enum StatusICO {
        Created,
        Started,
        Finished
    }
    StatusICO statusICO = StatusICO.Created;
    // Events Log
    event LogStartEmission();
    event LogFinishEmission();
    event LogBuyForInvestor(address investor, uint imtValue);

    // Modifiers
    // Allows execution by the manager only
    modifier managerOnly { 
        require(msg.sender == Manager);
        _; 
     }

    // Allows execution by the one of controllers only
    modifier controllersOnly {
        require(
            (msg.sender == Controller_Address1)||
            (msg.sender == Controller_Address2)||
            (msg.sender == Controller_Address3)
        );
        _;
    }

   /**
    *   @dev Contract constructor function
    */
    function MoneyTokenICO(
        address _ReserveFund,
        address _TeamFund,
        address _AdvisorsFund,
        address _BancorFund,
        address _BountyFund,
        address _Manager,
        address _Controller_Address1,
        address _Controller_Address2,
        address _Controller_Address3
        ) public {
        ReserveFund = _ReserveFund;
        TeamFund = _TeamFund;
        AdvisorsFund = _AdvisorsFund;
        BancorFund = _BancorFund;
        BountyFund = _BountyFund;
        Manager = _Manager;
        Controller_Address1 = _Controller_Address1;
        Controller_Address2 = _Controller_Address2;
        Controller_Address3 = _Controller_Address3;
    }

   /**
    *   @dev Function to start emission
    *   Sets ICO status to Started 
    */
    function startEmission() external managerOnly {
        require(statusICO == StatusICO.Created);
        statusICO = StatusICO.Started;
        LogStartEmission();
    }

   /**
    *   @dev Function to finish emission
    *   Sets ICO status to Finished and  emits tokens for funds
    */
    function finishEmission() external managerOnly {
        require(statusICO == StatusICO.Started);
        uint alreadyMinted = IMT.totalSupply();
        uint totalAmount = alreadyMinted.mul(100).div(publicIcoPart);
        IMT.mintTokens(ReserveFund, reservePart.mul(totalAmount).div(100));
        IMT.mintTokens(TeamFund, teamPart.mul(totalAmount).div(100));
        IMT.mintTokens(AdvisorsFund, advisorsPart.mul(totalAmount).div(100));
        IMT.mintTokens(BancorFund, bancorPart.mul(totalAmount).div(100));
        IMT.mintTokens(BountyFund, bountyPart.mul(totalAmount).div(100));
        statusICO = StatusICO.Finished;
        IMT.defrost();
        LogFinishEmission();
    }

   /**
    *   @dev Function to issues tokens
    *   @param _investor     address the tokens will be issued to
    *   @param _imtValue     number of IMT tokens
    *   @param _bonusPart    bonus percent
    */

    function buyForInvestor(
        address _investor, 
        uint _imtValue, 
        uint _bonusPart
    ) 
        external 
        controllersOnly {
        require(statusICO == StatusICO.Started);
        uint bonus = _imtValue.mul(_bonusPart).div(100);
        uint total = _imtValue.add(bonus);
        require (soldAmount + total <= hardCap);
        soldAmount = soldAmount.add(total);
        IMT.mintTokens(_investor, total);
        LogBuyForInvestor(_investor, total);
    }
}

/**
 *   @title ImtToken
 *   @dev IMT token contract
 */
contract ImtToken is ERC20 {
    using SafeMath for uint;
    string public name = "MoneyToken";
    string public symbol = "IMT";
    uint public decimals = 18;

    // Ico contract address
    address public ico;
    
    // Tokens transfer ability status
    bool public tokensAreFrozen = true;

    // Allows execution by the owner only
    modifier icoOnly { 
        require(msg.sender == ico); 
        _; 
    }

   /**
    *   @dev Contract constructor function sets Ico address
    *   @param _ico          ico address
    */
    function ImtToken(address _ico) public {
       ico = _ico;
    }

   /**
    *   @dev Function to mint tokens
    *   @param _holder       beneficiary address the tokens will be issued to
    *   @param _value        number of tokens to issue
    */
    function mintTokens(address _holder, uint _value) external icoOnly {
       require(_value > 0);
       balances[_holder] = balances[_holder].add(_value);
       totalSupply = totalSupply.add(_value);
       Transfer(0x0, _holder, _value);
    }


   /**
    *   @dev Function to enable token transfers
    */
    function defrost() external icoOnly {
       tokensAreFrozen = false;
    }

   /**
    *   @dev Get balance of tokens holder
    *   @param _holder        holder's address
    *   @return               balance of investor
    */
    function balanceOf(address _holder) constant returns (uint256) {
         return balances[_holder];
    }

   /**
    *   @dev Send coins
    *   throws on any error rather then return a false flag to minimize
    *   user errors
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transfer(address _to, uint256 _amount) public returns (bool) {
        require(!tokensAreFrozen);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

   /**
    *   @dev An account/contract attempts to get the coins
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   @param _from         source address
    *   @param _to           target address
    *   @param _amount       transfer amount
    *
    *   @return true if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        require(!tokensAreFrozen);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
     }


   /**
    *   @dev Allows another account/contract to spend some tokens on its behalf
    *   throws on any error rather then return a false flag to minimize user errors
    *
    *   also, to minimize the risk of the approve/transferFrom attack vector
    *   approve has to be called twice in 2 separate transactions - once to
    *   change the allowance to 0 and secondly to change it to the new allowance
    *   value
    *
    *   @param _spender      approved address
    *   @param _amount       allowance amount
    *
    *   @return true if the approval was successful
    */
    function approve(address _spender, uint256 _amount) public returns (bool) {
        require((_amount == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

   /**
    *   @dev Function to check the amount of tokens that an owner allowed to a spender.
    *
    *   @param _owner        the address which owns the funds
    *   @param _spender      the address which will spend the funds
    *
    *   @return              the amount of tokens still avaible for the spender
    */
    function allowance(address _owner, address _spender) constant returns (uint256) {
        return allowed[_owner][_spender];
    }
}
