// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRegist{
    function isAuthSpell(address spell) external view returns(bool);
}

contract Vote {
    struct proposalMsg {
        uint256 index;
        address spell;
        address sender;
        uint256 expire;
        string desc;
        address[] approvers; 
    }
    
    uint256 public count;
    uint256 public line;
    mapping (uint256=> proposalMsg) public pos;
    mapping (uint256=> bool) public pass;
    mapping (address=>mapping ( uint256=> bool)) public approver;
    event SendProposal(uint256 indexed id, address indexed  usr, address spell, string desc);
    
    function _setLine(uint256 l) internal {
        require(l>0, "Error Line");
        line = l;
    }

    function _sendProposal(address _spell, string memory _desc) internal {
        count++;
        address[] memory arr;
        pos[count]=proposalMsg(
            count,
            _spell,
            msg.sender,
            block.timestamp + 1 days,
            _desc,
            arr
        );

        pos[count].approvers.push(msg.sender);

        emit SendProposal(count, msg.sender, _spell, _desc);
    }

    function _vote(uint256 index) internal {
        require(pos[index].expire > block.timestamp, "proposal exprired");
        require(!approver[msg.sender][index], "approverd!");
        approver[msg.sender][index] = true;
        pos[index].approvers.push(msg.sender);
        if (pos[index].approvers.length == line){
            pass[index]=true;
        }
    }
}

contract Auth{
    mapping (address => bool) public signers;
    uint256 public signerCount;
    function _rely(address usr) internal  {require(usr != address(0) && !signers[usr], "Auth: error"); signers[usr] = true; signerCount++;}
    function _deny(address usr) internal  {require(usr != address(0) && signers[usr], "Auth: error"); signers[usr] = false; signerCount--;}
    modifier auth {
        require(signers[msg.sender], "not-authorized");
        _;
    }
}

contract SpellRegist is IRegist, Ownable, Vote, Auth{
    bool public pause;
    address public authFactory;
    mapping(address=>bool) internal authSpells;
    event Regist(address spell);

    constructor(address[] memory _signers){
        for(uint256 i=0; i< _signers.length; i++){
            _rely(_signers[i]);
        }
    }
    
    function setPause(bool flag) public onlyOwner { pause = flag;}
    function rely(address usr) public onlyOwner { _rely(usr); }
    function deny(address usr) public onlyOwner { _deny(usr); }
    function setLine(uint256 l) public onlyOwner {_setLine(l);}
    function setAuthFactory(address factory) public onlyOwner{
        require(factory != address(0), "factory can't be 0");
        authFactory = factory;
    }

    function sendProposal(address spell, string memory desc) public auth {
        require(!pause, "stop");
        _sendProposal(spell, desc);
    }

    function vote(uint index) public auth {
        _vote(index); 
        if (pass[index] && !authSpells[pos[index].spell]){ _regist(pos[index].spell);}
    }

    function _regist(address spell) internal{
        //require(!pause);
        authSpells[spell]= true;
        emit Regist(spell);
    }

    function isAuthSpell(address spell) public view override returns(bool){
        if (!pause){
             return authSpells[spell];
        }else {
             return IRegist(authFactory).isAuthSpell(spell);
        }
    }
}

