// SPDX-License-Identifier: MIT
// by 0xAA
pragma solidity ^0.8.4;

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./IERC721Metadata.sol";
import "./Address.sol";
import "./String.sol";

contract ERC721 is IERC721, IERC721Metadata{
    using Address for address; // 使用Address庫，用isContract来判斷地址是否為合約
    using Strings for uint256; // 使用String庫，

    // Token名稱
    string public override name;
    // Token代號
    string public override symbol;
    // tokenId 到 owner address 的持有人映射
    mapping(uint => address) private _owners;
    // address 到 持倉數量 的持倉量映射
    mapping(address => uint) private _balances;
    // tokenID 到 授權地址 的授權映射
    mapping(uint => address) private _tokenApprovals;
    //  owner地址。到operator地址 的批量授權映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * 構造函數，初始化`name` 和`symbol` .
     */
    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
    }

    // 實現IERC165接口supportsInterface
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    // 實現RC721的balanceOf，利用_balances變量查詢owner地址的balance。
    function balanceOf(address owner) external view override returns (uint) {
        require(owner != address(0), "owner = zero address");
        return _balances[owner];
    }

    // 實現IERC721的ownerOf，利用_owners變量查詢tokenId的owner。
    function ownerOf(uint tokenId) public view override returns (address owner) {
        owner = _owners[tokenId];
        require(owner != address(0), "token doesn't exist");
    }

    // 實現IERC721的isApprovedForAll，利用_operatorApprovals變量查詢owner地址是否将所持NFT批量授權给了operator地址。
    function isApprovedForAll(address owner, address operator)
        external
        view
        override
        returns (bool)
    {
        return _operatorApprovals[owner][operator];
    }

    // 實現IERC721的setApprovalForAll，將持有代幣全部授權给operator地址。調用_setApprovalForAll函數。
    function setApprovalForAll(address operator, bool approved) external override {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // 實現IERC721的getApproved，利用_tokenApprovals變量查询tokenId的授權地址。
    function getApproved(uint tokenId) external view override returns (address) {
        require(_owners[tokenId] != address(0), "token doesn't exist");
        return _tokenApprovals[tokenId];
    }
     
    // 授權函數。通過調整_tokenApprovals来，授權 to 地址操作 tokenId，同時釋放Approval事件。
    function _approve(
        address owner,
        address to,
        uint tokenId
    ) private {
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // 實現IERC721的approve，將tokenId授權给 to 地址。條件：to不是owner，且msg.sender是owner或授權地址。調用_approve函数。
    function approve(address to, uint tokenId) external override {
        address owner = _owners[tokenId];
        require(
            msg.sender == owner || _operatorApprovals[owner][msg.sender],
            "not owner nor approved for all"
        );
        _approve(owner, to, tokenId);
    }

    // 查詢 spender地址是否可以使用tokenId（他是owner或被授權地址）。
    function _isApprovedOrOwner(
        address owner,
        address spender,
        uint tokenId
    ) private view returns (bool) {
        return (spender == owner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[owner][spender]);
    }

    /*
     * 轉帳函數。通過調整_balances和_owner變量將 tokenId 從 from 轉帳给 to，同時釋放Transfer事件。
     * 條件:
     * 1. tokenId 被 from 擁有
     * 2. to 不是0地址
     */
    function _transfer(
        address owner,
        address from,
        address to,
        uint tokenId
    ) private {
        require(from == owner, "not owner");
        require(to != address(0), "transfer to the zero address");

        _approve(owner, address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    // 實現IERC721的transferFrom，非安全轉帳，不建議使用。調用_transfer函數
    function transferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _transfer(owner, from, to, tokenId);
    }

    /**
     * 安全轉帳，安全地將 tokenId 代幣從 from 轉移到 to，會检查合約接收者是否了解 ERC721 協議，以防止代幣
     被永久鎖定。調用了_transfer函數和_checkOnERC721Received函數。條件：
     * from 不能是0地址.
     * to 不能是0地址.
     * tokenId 代幣必须存在，并且被 from擁有.
     * 如果 to 是智能合约, 他必須支持 IERC721Receiver-onERC721Received.
     */
    function _safeTransfer(
        address owner,
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private {
        _transfer(owner, from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "not ERC721Receiver");
    }

    /**
     * 實現IERC721的safeTransferFrom，安全轉帳，調用了_safeTransfer函數。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) public override {
        address owner = ownerOf(tokenId);
        require(
            _isApprovedOrOwner(owner, msg.sender, tokenId),
            "not owner nor approved"
        );
        _safeTransfer(owner, from, to, tokenId, _data);
    }

    // safeTransferFrom重載函數
    function safeTransferFrom(
        address from,
        address to,
        uint tokenId
    ) external override {
        safeTransferFrom(from, to, tokenId, "");
    }

    /** 
     * 鑄造函數。通過調整_balances和_owners變量来鑄造tokenId並轉帳给 to，同時釋放Transfer事件。鑄造函數。通過調整_balances和_owners變量来鑄造tokenId並轉帳给 to，同時釋放Transfer事件。
     * 这个mint函數所有人都能調用，實際使用需要開發人員重寫，加上一些條件。
     * 條件:
     * 1. tokenId尚不存在。
     * 2. to不是0地址.
     */
    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "mint to zero address");
        require(_owners[tokenId] == address(0), "token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    //  銷毀函數，通過調整_balances和_owners變量来銷毀tokenId，同时釋放Transfer事件。條件：tokenId存在。
    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner of token");

        _approve(owner, address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    // _checkOnERC721Received：函數，用于在 to 為合約的時候調用IERC721Receiver-onERC721Received, 以防 tokenId 被不小心轉入黑洞。
    function _checkOnERC721Received(
        address from,
        address to,
        uint tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            return
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                ) == IERC721Receiver.onERC721Received.selector;
        } else {
            return true;
        }
    }

    /**
     * 實現IERC721Metadata的tokenURI函数，查詢metadata。
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_owners[tokenId] != address(0), "Token Not Exist");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    /**
     * 計算{tokenURI}的BaseURI，tokenURI就是把baseURI和tokenId拼接在一起，需要開發重寫。
     * BAYC的baseURI為ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
     */
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}