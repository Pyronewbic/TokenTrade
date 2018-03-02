pragma solidity ^0.4.18;

import "./Owner.sol";
import "./EIP20Interface.sol";
// import "./TradeInterface.sol";

contract TokenTrade is Owner,EIP20Interface {

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
   
    string public name;                   
    uint8 public decimals;                
    string public symbol;
    uint64 public conversionRate;

    event Deposit(address indexed _owner, uint256 _value);
    event Withdraw(address indexed _owner, uint256 _value);

    function TokenTrade(
        uint256 _initialAmount,
        uint8 _decimalUnits,
        uint8 _conversionRate,
        string _tokenName,
        string _tokenSymbol
    ) public {
        balances[owner] = _initialAmount;               
        totalSupply = _initialAmount;                        
        decimals = _decimalUnits;
        conversionRate = 1000000000000000000/_conversionRate;                            
        name = _tokenName;                                   
        symbol = _tokenSymbol;
        Transfer(owner,owner,totalSupply);
    }

    function () public payable {
        deposit(msg.sender);
    }   

    function deposit(address _owner) public payable returns (bool success){
        require(msg.value>1);
        uint256 dep_amount = msg.value/conversionRate;
        balances[_owner] += dep_amount;
        totalSupply += dep_amount;
        Deposit(_owner,dep_amount);
        return true;
    }

    function withdraw(uint256 _value) public onlyOwner returns (bool success){
        owner.transfer(_value*1000000000000000000); //in wei
        Withdraw(owner,_value*1000000000000000000);
        return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }   
}