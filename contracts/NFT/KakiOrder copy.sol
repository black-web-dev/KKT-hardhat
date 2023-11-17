//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract KakiOrder is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _nftIds;

    enum NftType {
        BASIC,
        COMMON,
        RARE,
        LEGENDARY
    }

    NftType public nftType;

    struct NftTypeDetail {
        string baseURI;
        NftType nftType;
        uint256 price;
        uint256 increasePrice;
        uint256 mintedAmount;
        uint256 maxAmount;
    }

    struct NftItem {
        NftType nftType;
        uint256 nftId;
    }

    mapping(NftType => NftTypeDetail) public _nftTypeDetails;
    mapping(uint => NftItem) public _nftItems;

    uint256 public _maxAmount = 10000;

    constructor() ERC721("KakiOrder", "kaki") {
        _nftTypeDetails[NftType.BASIC] = NftTypeDetail(
            "https://ipfs.io/ipfs/Qmec7774qYV94Sw6wgL6cqSbd966cwkehFQwfLawRWTNff/",
            NftType.BASIC,
            50,
            0,
            0,
            500
        );
        _nftTypeDetails[NftType.COMMON] = NftTypeDetail(
            "https://ipfs.io/ipfs/Qmec7774qYV94Sw6wgL6cqSbd966cwkehFQwfLawRWTNff/",
            NftType.BASIC,
            100,
            10,
            0,
            500
        );
        _nftTypeDetails[NftType.RARE] = NftTypeDetail(
            "https://ipfs.io/ipfs/Qmec7774qYV94Sw6wgL6cqSbd966cwkehFQwfLawRWTNff/",
            NftType.BASIC,
            5000,
            100,
            0,
            500
        );
        _nftTypeDetails[NftType.LEGENDARY] = NftTypeDetail(
            "https://ipfs.io/ipfs/Qmec7774qYV94Sw6wgL6cqSbd966cwkehFQwfLawRWTNff/",
            NftType.BASIC,
            0,
            0,
            0,
            500
        );
    }

    function baseURI(NftType nftType) public view returns (string memory) {
        return _nftTypeDetails[nftType].baseURI;
    }

    function getCurrentMintPrice(
        NftType nftType,
        uint256 nftId
    ) public view returns (uint256) {
        return
            _nftTypeDetails[nftType].price +
            _nftTypeDetails[nftType].increasePrice *
            nftId;
    }

    function mint(NftType nftType) external payable {
        uint256 mintedAmount = _nftTypeDetails[nftType].mintedAmount;
        uint256 mintPrice = getCurrentMintPrice(nftType, mintedAmount + 1);

        require(
            mintedAmount < _nftTypeDetails[nftType].maxAmount,
            "Overflow amount of nft"
        );

        require(
            msg.value >= mintPrice,
            "Msg value should be over the mint price"
        );

        payable(msg.sender).transfer(msg.value - mintPrice);

        _nftIds.increment();
        uint256 newItemId = _nftIds.current();

        _nftTypeDetails[nftType].mintedAmount++;

        _mint(msg.sender, newItemId);

        _setTokenURI(
            newItemId,
            string(
                abi.encodePacked(
                    _nftTypeDetails[nftType].baseURI,
                    Strings.toString(newItemId)
                )
            )
        );

        NftItem memory newItem = NftItem(nftType, newItemId);
        _nftItems[newItemId] = newItem;
    }

    function getNftItemsByAddress(
        address _owner
    ) public view returns (NftItem[] memory) {
        uint256 totalSupply = _nftIds.current();

        NftItem[] memory details = new NftItem[](balanceOf(_owner));

        for (uint256 i = 0; i < totalSupply; i++) {
            if (ownerOf(_nftItems[i + 1].nftId) == _owner) {
                details[i] = _nftItems[i + 1];
            }
        }

        return details;
    }
}
