pragma solidity ^0.4.18;

contract Owner {
    
    address public owner;
    address public newOwner;
    
    event ownershipTransferred(address indexed _from, address indexed _to);
    
    modifier onlyOwner(){
        require(msg.sender==owner);
        _;
    }
    
    function Owner() public{
        owner = msg.sender;
    }

    function killContract() public onlyOwner{
        selfdestruct(owner);
    }

    function transferOwnership(address _newAddress) public onlyOwner{
        require(_newAddress!=address(0));   
        if(_newAddress!=owner){
            newOwner = _newAddress;
        }
    }
    
    function acceptOwnership() public{
        require(msg.sender==newOwner);
        ownershipTransferred(owner,newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}