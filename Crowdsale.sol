pragma solidity ^0.4.19;
import "Token.sol";
contract CrowdSale is Ownable
{
    using SafeMath for uint256;
    Token public token=new Token();
    address investmentWallet; 
    uint restrictedPercent;//percent of tokens for inventors
    address restricted;//address for restricted tokens
    uint start; //time of crowdsale start in unix format
    uint period;//period of crowdsale
    uint hardcap;//maximum value of investments
    uint softcap;//minimum value to start project
    uint rate;//rate token-ETH
    bool refundIsOn=false;
    mapping (address => uint256) investments;
    //hardcap is not reached yet
    modifier underHardCap{
        require(investmentWallet.balance<hardcap);
        _;
    }
    //ico is on
    modifier saleIsOn{
        require(now>=start && now<=start+period*1 days);
        _;
    } 
    //function that mint tokens using the rate and bonus program
    function mintTokens() underHardCap saleIsOn public payable{
        investments[msg.sender]=investments[msg.sender].add(msg.value);
        uint coeff=100;//coefficient for bonus program
        if (now<start+20*(1 days)) coeff=105;
        if (now<start+10*(1 days)) coeff=115;
        uint256 amount=rate.mul(msg.value).div(1 ether);
        amount=amount.mul(coeff).div(100);
        token.mint(msg.sender, amount);
    }
    //function stops minting tokens and starts refunding is softcap was not reached  
    function stopMinting() onlyOwner public{
        require(now>start+period*1 days); //owner can stop stop minting only if the sale is over
        if (this.balance>=softcap){
            investmentWallet.transfer(this.balance);
            uint256 amount=token.totalSupply().mul(restrictedPercent).div(100-restrictedPercent);
            token.mint(restricted, amount);
        }
        else
        {
            StartRefunding();
            refundIsOn=true;
        }
        token.finishMinting();
    }
    //function refund investor's money if refund is on
    function refund() public{
        require(refundIsOn);
        uint256 investment = investments[msg.sender];
        investments[msg.sender]=0;
        msg.sender.transfer(investment);
        Refund(msg.sender, investment);
    }
    function () external payable{
        mintTokens();
    }
    event StartRefunding();
    event Refund(address to, uint256 amount);
}