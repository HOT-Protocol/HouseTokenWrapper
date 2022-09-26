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
       // address[] approvers; 
    }
    
    uint256 public lastId;                                              //last of proposals Id
    uint256 public line;                                                //line of proposals passed
    mapping (uint256=> proposalMsg) public pom;                         //proposal MSG  
    mapping (uint256=> address[]) public poa;                           //proposal approves
    mapping (address=> uint256) public sopi;                            //spell of proposal's id
    mapping (uint256=> bool) public popi;                               //passed of proposal's id
 
    event SendProposal(uint256 indexed id, address indexed  usr, address spell, string desc);
    event VoteProposal(uint256 indexed id, address indexed usr);
    
    function _setLine(uint256 _line) internal {
        require(_line >0, "Error Line");
        line = _line;
    }

    function _sendProposal(address _spell, string memory _desc) internal {
        require(sopi[_spell] == 0, "proposal exists");
        lastId++;
        pom[lastId]=proposalMsg(
            lastId,
            _spell,
            msg.sender,
            block.timestamp + 1 days,
            _desc
        );

        poa[lastId].push(msg.sender);
        sopi[_spell]=lastId;

        emit SendProposal(lastId, msg.sender, _spell, _desc);
    }

    function _isApproved(address usr, uint256 id) internal view returns(bool) {
        if (poa[id].length == 0){ return false;}
        for (uint256 i=0; i < poa[id].length; i++){
            if(poa[id][i] == usr) {return true;}
        }
        return false;
    }

    function _vote(uint256 id) internal {
        require(pom[id].expire > block.timestamp, "proposal exprired");
        require(!_isApproved(msg.sender, id), "caller was approverd");

        poa[id].push(msg.sender);
        if (poa[id].length == line){
            popi[id]=true;
        }

        emit VoteProposal(id, msg.sender);
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

    constructor(uint256 _line, address[] memory _signers){
        line = _line;
        for(uint256 i=0; i< _signers.length; i++){
            _rely(_signers[i]);
        }
    }
    function setPause(bool flag) public onlyOwner { pause = flag;}
    function rely(address usr) public onlyOwner { _rely(usr);}
    function deny(address usr) public onlyOwner { _deny(usr);}
    function setLine(uint256 l) public onlyOwner {_setLine(l);}
    function setAuthFactory(address factory) public onlyOwner{
        require(factory != address(0), "factory can't be 0");
        authFactory = factory;
    }

    function sendProposal(address spell, string memory desc) public auth {
        require(!pause, "stop");
        _sendProposal(spell, desc);
    }

    function vote(uint id) public auth {
        require(!pause, "stop");
        _vote(id); 
        address spell = pom[id].spell;
        if (popi[id] && !authSpells[spell]){ _regist(spell);}
    }

    function _regist(address spell) internal{
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

