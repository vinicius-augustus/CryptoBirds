// SPDX-License-Identifier: MIT
pragma solidity >=0.4.16 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Token is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // define crypto bird struct
    struct CryptoBird {
        uint256 tokenId;
        string tokenName;
        string tokenURI;
        address payable mintedBy;
        address payable currentOwner;
        address payable previousOwner;
        uint256 price;
        uint256 numberOfTransfers;
        bool forSale;
    }

    CryptoBird[] public cryptobirds;

    // map cryptobird's token id to crypto bird
    mapping(uint256 => CryptoBird) public allCryptoBirds;
    // check if token name exists
    mapping(string => bool) public tokenNameExists;
    // check if token URI exists
    mapping(string => bool) public tokenURIExists;

    // initialize contract while deployment with contract's collection name and token
    constructor() ERC721("MyToken", "TKN") {}

    function mintToken(
        address player,
        string memory name,
        string memory tokenURI,
        uint256 price
    ) public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        require(msg.sender != address(0));
        require(!tokenURIExists[tokenURI]);
        require(!tokenNameExists[name]);

        _mint(player, newItemId);
        _setTokenURI(newItemId, tokenURI);

        tokenNameExists[name] = true;
        tokenURIExists[tokenURI] = true;

        CryptoBird memory newCryptoBird = CryptoBird(
            newItemId,
            name,
            tokenURI,
            payable(msg.sender),
            payable(msg.sender),
            payable(address(0)),
            price,
            0,
            true
        );

        allCryptoBirds[newItemId] = newCryptoBird;
    }

    function changePrice(uint256 _tokenId, uint256 _newPrice) public {
        address tokenOwner = ownerOf(_tokenId);
        require(msg.sender != address(0));
        require(tokenOwner == msg.sender);
        CryptoBird memory cryptobird = allCryptoBirds[_tokenId];
        cryptobird.price = _newPrice;
        allCryptoBirds[_tokenId] = cryptobird;
    }

    function buyToken(uint256 _tokenId) public payable {
        address tokenOwner = ownerOf(_tokenId);
        CryptoBird memory cryptobird = allCryptoBirds[_tokenId];

        require(msg.sender != address(0));
        require(tokenOwner != address(0));
        require(tokenOwner != msg.sender);
        require(msg.value >= cryptobird.price);
        require(cryptobird.forSale);
        _transfer(tokenOwner, msg.sender, _tokenId);
        address payable sendTo = cryptobird.currentOwner;
        sendTo.transfer(msg.value);
        cryptobird.previousOwner = cryptobird.currentOwner;
        cryptobird.currentOwner = payable(msg.sender);
        cryptobird.numberOfTransfers += 1;
        allCryptoBirds[_tokenId] = cryptobird;
    }
}
