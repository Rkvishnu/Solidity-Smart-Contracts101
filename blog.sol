//SPDX-License-Identifier:MIT
pragma solidity 0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters/Counters.sol"

contract Medium is ERC721,ERC721URIStorage,Ownable{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCOunter;
    uint256 public fees;

    constructor(
        string memory _name,
        string memory  _symbol,
        uint256 _fees
    )ERC721(_name,_symbol){
        fees=_fees;
    }

    function safeMint(address to, string memory uri) public payable{
        require(msg.value>=fees,"not enough MATIC");
        payable(owner()).transfer(fees);

        //MintNFT

        uint256 tokenId=_tokenIdCounter.current();
     _tokenIdCounter.increment();
     _safeMint(to,tokenId);
     _setTokenURI(tokenId,uri);

     //returning overrsupplied fees
     
     uint256 contractBlalance=address(this).balance;

     if(contractBalance >0){
        payable(msg.sender).transfer(address(this).balance);
     }



    }
}

