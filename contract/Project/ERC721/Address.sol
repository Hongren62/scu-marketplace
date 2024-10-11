// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

// Address庫
library Address {
    // 利用extcodesize判斷一個地址是否為合約地址
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}