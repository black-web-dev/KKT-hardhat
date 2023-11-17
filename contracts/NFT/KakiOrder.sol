// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

interface IKKT {
    function burn(uint256 amount) external;
}

contract BasicNFT is
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable,
    IERC721ReceiverUpgradeable
{
    using Counters for Counters.Counter;
    Counters.Counter private ids;

    struct Stake {
        uint256 id;
        bool isUnstaked;
    }

    string public baseURI;
    mapping(uint256 => string) private tokenURIs;

    mapping(address => mapping(uint256 => Stake)) public stakesByIndex;
    mapping(address => mapping(uint256 => bool)) public stakesByAddressId;
    mapping(address => uint256) public stakeLengths;

    ISwapRouter public swapRouter;
    address public kktToken;
    address public usdtToken;
    address public feeReceiver;

    uint public maxCount;
    uint public countForLegendary;
    uint24 private poolFee;

    function initialize(
        string memory _baseURI,
        address _feeReceiver,
        address _kktToken,
        address _usdtToken,
        ISwapRouter _swapRouter,
        uint _maxCount,
        uint _countForLegendary
    ) public initializer {
        __Ownable_init();
        __ERC721_init("KakiBasicNFT", "KKBNFT");
        baseURI = _baseURI;
        feeReceiver = _feeReceiver;
        kktToken = _kktToken;
        usdtToken = _usdtToken;
        swapRouter = _swapRouter;
        maxCount = _maxCount;
        countForLegendary = _countForLegendary;
        poolFee = 3000;
    }

    function mint() external {
        uint256 mintedCount = ids.current();

        // require(mintedCount < maxCount, "Overflow count of Basic NFT");

        // uint256 price = 50;
        // uint256 priceWei = price * 1000000;

        // require(
        //     IERC20(usdtToken).balanceOf(msg.sender) >= priceWei,
        //     "USDT amount is not enough"
        // );

        // IERC20(usdtToken).transferFrom(
        //     msg.sender,
        //     feeReceiver,
        //     (priceWei * 95) / 100
        // );

        // // Swap Implementation
        // uint256 amountIn = (priceWei * 5) / 100;

        // TransferHelper.safeTransferFrom(
        //     usdtToken,
        //     msg.sender,
        //     address(this),
        //     amountIn
        // );
        // TransferHelper.safeApprove(usdtToken, address(swapRouter), amountIn);

        // ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
        //     .ExactInputSingleParams({
        //         tokenIn: usdtToken,
        //         tokenOut: kktToken,
        //         fee: poolFee,
        //         recipient: address(this),
        //         deadline: block.timestamp,
        //         amountIn: amountIn,
        //         amountOutMinimum: 0,
        //         sqrtPriceLimitX96: 0
        //     });

        // uint outAmount = swapRouter.exactInputSingle(params);

        // // Burn Token
        // IKKT(kktToken).burn(outAmount);

        // Create NFT
        ids.increment();
        uint256 createdNFTId = ids.current();
        _mint(msg.sender, createdNFTId);
        _setTokenURI(
            createdNFTId,
            string(abi.encodePacked(baseURI, Strings.toString(createdNFTId)))
        );
    }

    function staking(uint id) external {
        require(ownerOf(id) == msg.sender, "Owner don't have this nft!");
        require(
            isApprovedForAll(msg.sender, address(this)),
            "Not approve nft to staker"
        );

        safeTransferFrom(msg.sender, address(this), id);

        if (stakesByAddressId[msg.sender][id]) {
            uint len = stakeLengths[msg.sender];
            for (uint i = 0; i < len; i++) {
                if (stakesByIndex[msg.sender][i].id == id) {
                    stakesByIndex[msg.sender][i].isUnstaked = false;
                }
            }
        } else {
            stakesByIndex[msg.sender][stakeLengths[msg.sender]] = Stake(
                id,
                false
            );
            stakeLengths[msg.sender]++;
        }

        stakesByAddressId[msg.sender][id] = true;
    }

    function unstaking(uint id) external {
        require(
            ownerOf(id) == address(this),
            "Contract doesn't have this nft!"
        );

        if (stakesByAddressId[msg.sender][id]) {
            uint len = stakeLengths[msg.sender];
            for (uint i = 0; i < len; i++) {
                if (
                    stakesByIndex[msg.sender][i].id == id &&
                    stakesByIndex[msg.sender][i].isUnstaked == false
                ) {
                    // address(this).approve(msg.sender, id);
                    IERC721(address(this)).transferFrom(address(this), msg.sender, id);
                    stakesByIndex[msg.sender][i].isUnstaked = true;
                }
            }
        }
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        require(_exists(tokenId), "URI set of nonexistent token");
        tokenURIs[tokenId] = _tokenURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = tokenURIs[tokenId];

        return _tokenURI;
    }

    function tokenIdsOfOwner(
        address _owner
    ) public view returns (uint256[] memory) {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
