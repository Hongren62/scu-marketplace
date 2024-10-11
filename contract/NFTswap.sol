// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../Project/ERC721/IERC721.sol";
import "../Project/ERC721/IERC721Receiver.sol";
import "../Project/ERC721/SCUtest.sol";

contract ERC721Receiver is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}

contract NFTSwap is ERC721Receiver {
    event List(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Purchase(
        address indexed buyer,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 price
    );
    event Revoke(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId
    );
    event Update(
        address indexed seller,
        address indexed nftAddr,
        uint256 indexed tokenId,
        uint256 newPrice
    );

    struct Order {
        address owner;
        uint256 price;
    }

    mapping(address => mapping(uint256 => Order)) public nftList;

    // 允許直接接收Ether
    receive() external payable {}

    // 後備函數，處理所有其他調用
    fallback() external payable {}

    // 掛單: 賣家上架NFT，合約地址為_nftAddr，tokenId為_tokenId，價格_price為以太坊（單位是wei）
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval"); // 合約需要獲得授權
        require(_price > 0, "Price must be greater than 0"); // 價格必須大於0

        Order storage _order = nftList[_nftAddr][_tokenId]; // 設置NFT持有人和價格
        _order.owner = msg.sender;
        _order.price = _price;

        _nft.safeTransferFrom(msg.sender, address(this), _tokenId); // 將NFT轉賬到合約

        emit List(msg.sender, _nftAddr, _tokenId, _price); // 發出List事件
    }

    // 購買: 買家購買NFT，合約為_nftAddr，tokenId為_tokenId，調用函數時要附帶ETH
    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId]; // 取得Order
        require(_order.price > 0, "Invalid Price"); // NFT價格必須大於0
        require(msg.value >= _order.price, "Increase price"); // 購買價格必須大於或等於標價

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // 確保NFT在合約中

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId); // 將NFT轉給買家
        payable(_order.owner).transfer(_order.price); // 將ETH轉給賣家
        payable(msg.sender).transfer(msg.value - _order.price); // 多餘ETH退還給買家

        delete nftList[_nftAddr][_tokenId]; // 刪除order

        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price); // 發出Purchase事件
    }

    // 撤單：賣家取消掛單
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId]; // 取得Order
        require(_order.owner == msg.sender, "Not Owner"); // 必須由持有人發起

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // 確保NFT在合約中

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId); // 將NFT轉給賣家
        delete nftList[_nftAddr][_tokenId]; // 刪除order

        emit Revoke(msg.sender, _nftAddr, _tokenId); // 發出Revoke事件
    }

    // 調整價格: 賣家調整掛單價格
    function update(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _newPrice
    ) public {
        require(_newPrice > 0, "Invalid Price"); // NFT價格必須大於0
        Order storage _order = nftList[_nftAddr][_tokenId]; // 取得Order
        require(_order.owner == msg.sender, "Not Owner"); // 必須由持有人發起

        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // 確保NFT在合約中

        _order.price = _newPrice; // 調整NFT價格

        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice); // 發出Update事件
    }
}