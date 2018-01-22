pragma solidity ^0.4.19;
//library for mathematical operations to avoid overflow
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a / b;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    require(b <= a); 
    c = a - b;
  } 
  
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) { 
    c = a + b;
    require(c >= a);
  }
}
//implementation of ERC20 standart
contract BaseToken
{
    using SafeMath for uint256;
    uint256 public totalSupply = 0; 
    mapping (address => uint256) balances; 
    mapping (address => mapping(address => uint256)) allowed; 
    // return balance of tokens of owner 
    function balanceOf(address owner) public constant returns (uint256 balance){
      return balances[owner];   
    }
    //transfer value of money from wallet of msg.sender to wallet to
    function transfer(address to, uint256 value) public returns(bool success){
        if (balances[msg.sender]<value) return false;
        balances[msg.sender]=balances[msg.sender].sub(value);
        balances[to]=balances[to].add(value);
        Transfer(msg.sender, to, value);
        return true;
    }
    //transfer value of money from wallet from to wallet to(if this operation is allowed by owner of from wallet)
    function transferFrom(address from, address to, uint256 value) public returns(bool success){
        require(to != address(0));
        if (value>allowed[from][to] || balances[from]<value) return false;
        balances[from]=balances[from].sub(value);
        balances[to]=balances[to].add(value);
        allowed[from][to]=allowed[from][to].sub(value);
        Transfer(from, to, value);
        return true;
    }
    //allow to owner's of spender wallet to spend less than maxValue from msg.sender's wallet
    function approve(address spender, uint256 maxValue) public returns (bool success){
        require(spender!=address(0));
        allowed[msg.sender][spender]=maxValue;
        Approval(msg.sender, spender, maxValue);
        return true;
    }
    //return amount of money that msg.sender allow spender to spend 
    function allowance(address owner, address spender) public constant returns (uint256 maxValue){
        return allowed[owner][spender];
    }
    //increase amount of money that msg.sender allow spender to spend 
    function increaseApproval(address spender, uint256 valueToAdd) public returns (bool success){
        allowed[msg.sender][spender]=allowed[msg.sender][spender].add(valueToAdd);
        Approval(msg.sender, spender, allowed[msg.sender][spender]); 
        return true;
    }
    //decrease amount of money that msg.sender allow spender to spend 
    function decreaseApproval(address spender, uint256 valueToSubtract) public returns (bool success){
        if (valueToSubtract>allowed[msg.sender][spender]){
            allowed[msg.sender][spender]=0;
        }
        else{
            allowed[msg.sender][spender]=allowed[msg.sender][spender].sub(valueToSubtract);
        }
        Approval(msg.sender, spender, allowed[msg.sender][spender]); 
        return true;
    }
    event Transfer(address sender, address receiver, uint256 value);
    event Approval(address sender, address spender, uint256 maxValue);
}
//implementation of access only for the owner
contract Ownable
{
    address public contractOwner;
    function Ownable() public {
        contractOwner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        contractOwner = newOwner;
    }
}
//functional for issuing new coins
contract Mintable is Ownable, BaseToken
{
    bool public mintIsFinished=false;
    address public saleAgent = contractOwner;
    function mint(address to, uint256 value) public returns (bool success) {
        require(msg.sender==contractOwner || msg.sender==saleAgent);
        require(!mintIsFinished);
        balances[to]=balances[to].add(value);
        totalSupply=totalSupply.add(value);
        Mint(to, value);
        return true;
    }
    function finishMinting() public returns (bool){
        require(msg.sender==contractOwner || msg.sender==saleAgent);
        require(!mintIsFinished);
        mintIsFinished=true;
        MintFinished();
        return true;
    }
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
}
//ready for use token
contract Token is Ownable, BaseToken, Mintable
{
    string public constant name = "MeowMeowCoin";
    string public constant symbol = "MMC";
    uint8 public constant decimals = 18;
}