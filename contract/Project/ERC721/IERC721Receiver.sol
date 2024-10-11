// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ERC721接收者接口：合約必須實現这个接口来通過安全轉帳接收ERC721
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}