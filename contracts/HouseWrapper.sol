// contracts/HouseTokenFactory.sol
// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./HouseWrap.sol";

interface houseToken is IERC721Metadata{
    function mint(address) external returns(uint256);
}

contract HouseWrapper is Ownable {
    using Strings for uint256;
    
    houseToken public immutable erc721;
    mapping(address => mapping(uint256=>address)) public wrapOf;
    event Wrapper(address nft, uint256 tokenId, address wrap, address owner);

    // --- Auth ---
    mapping (address => uint256) public wards;
    function rely(address usr) external auth {  wards[usr] = 1; }
    function deny(address usr) external auth {  wards[usr] = 0; }
    modifier auth {
        require(owner() == msg.sender || wards[msg.sender] == 1 , "not-authorized");
        _;
    }

    constructor(address _houseToken){
        erc721 = houseToken(_houseToken);
    }

    function mint(address to) public auth returns (uint256, HouseWrap) {
        require(to != address(0), "HouseTokenFactory: zero address");

        uint256 newTokenId = erc721.mint(to);

        HouseWrap wrap = new HouseWrap(
            erc721,
            newTokenId,
            string(abi.encodePacked(erc721.symbol(), newTokenId.toString()))
        );

        wrapOf[address(erc721)][newTokenId]=address(wrap);

        emit Wrapper(address(erc721), newTokenId, address(wrap), to);

        return (newTokenId, wrap);
    }

    function mint(address to, uint256 mintAmount) public onlyOwner{
        require(to != address(0), "HouseTokenFactory: zero address");
        for(uint256 i=0; i< mintAmount; i++){
            uint256 newTokenId = erc721.mint(to);

            HouseWrap wrap = new HouseWrap(
                erc721,
                newTokenId,
                string(abi.encodePacked(erc721.symbol(), "_", newTokenId.toString()))
            );

            wrapOf[address(erc721)][newTokenId]=address(wrap);

            emit Wrapper(address(erc721), newTokenId, address(wrap), to);
        }
    }

    function wrapper(address nft, uint256 tokenId, address owner) public auth {
        require(IERC721Metadata(nft).ownerOf(tokenId) == owner, "HouseTokenFactory: token ownership errors");

        HouseWrap wrap = new HouseWrap(
                erc721,
                tokenId,
                string(abi.encodePacked(erc721.symbol(), "_", tokenId.toString()))
            );
        wrapOf[nft][tokenId]=address(wrap);

        emit Wrapper(nft, tokenId, address(wrap), owner);
    }
}
