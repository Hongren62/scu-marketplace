// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev ERC165標準接口, 詳見
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * 合約可以聲明支持的接口，供其他合約檢查
 *
 */
interface IERC165 {
    /**
     * @dev 如果合約實現了查詢的`interfaceId`，則返回true
     * 規則詳見：https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     *
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}