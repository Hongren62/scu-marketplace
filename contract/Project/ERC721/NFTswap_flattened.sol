
// File: 專題/ERC721/IERC165.sol



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
// File: 專題/ERC721/IERC721.sol



pragma solidity ^0.8.0;

/**
 * @dev ERC721標準接口.
 */
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function approve(address to, uint256 tokenId) external;

    function setApprovalForAll(address operator, bool _approved) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
// File: 專題/ERC721/IERC721Receiver.sol


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
// File: 專題/ERC721/IERC721Metadata.sol


pragma solidity ^0.8.0;

interface IERC721Metadata {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}
// File: 專題/ERC721/Address.sol


pragma solidity ^0.8.1;

// Address庫
library Address {
    // 利用extcodesize判斷一个地址是否為合约地址
    function isContract(address account) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}
// File: 專題/ERC721/String.sol


// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.21;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}
// File: 專題/ERC721/ERC721.sol


// by 0xAA
pragma solidity ^0.8.4;

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
// File: 專題/ERC721/SCUtest.sol


// by 0xAA
pragma solidity ^0.8.21;

contract SCUtest is ERC721{
    uint public MAX_APES = 10000; // 總量

    // 構造函數
    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_){
    }

    //BAYC的baseURI為ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/ 
    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmeSjSinHpPnmXmspMjwiXyN6zS4E9zccariGR3jxcaWtq/";
    }
    
    // 鑄造函數
    function mint(address to, uint tokenId) external {
        require(tokenId >= 0 && tokenId < MAX_APES, "tokenId out of range");
        _mint(to, tokenId);
    }
}
// File: 專題/ERC721/NFTswap.sol


pragma solidity ^0.8.21;

contract NFTSwap is IERC721Receiver {
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

    // 定義order結構體
    struct Order {
        address owner;
        uint256 price;
    }
    // NFT Order映射
    mapping(address => mapping(uint256 => Order)) public nftList;

    fallback() external payable {}

    // 掛單: 賣家上架NFT，合約地址為_nftAddr，tokenId為_tokenId，價格_price為以太坊（單位是wei）
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr); // 聲明IERC721介面合約變量
        require(_nft.getApproved(_tokenId) == address(this), "Need Approval"); // 合約得到授權
        require(_price > 0); // 價格大於0

        Order storage _order = nftList[_nftAddr][_tokenId]; // 設置NFT持有人和價格
        _order.owner = msg.sender;
        _order.price = _price;
        // 將NFT轉賬到合約
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        // 釋放List事件
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    // 購買: 買家購買NFT，合約為_nftAddr，tokenId為_tokenId，調用函數時要附帶ETH
    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId]; // 取得Order
        require(_order.price > 0, "Invalid Price"); // NFT價格大於0
        require(msg.value >= _order.price, "Increase price"); // 購買價格大於標價
        // 聲明IERC721介面合約變量
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合約中

        // 將NFT轉給買家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        // 將ETH轉給賣家，多餘ETH給買家退款
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        delete nftList[_nftAddr][_tokenId]; // 刪除order

        // 釋放Purchase事件
        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);
    }

    // 撤單： 賣家取消掛單
    function revoke(address _nftAddr, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddr][_tokenId]; // 取得Order
        require(_order.owner == msg.sender, "Not Owner"); // 必須由持有人發起
        // 聲明IERC721介面合約變量
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合約中

        // 將NFT轉給賣家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddr][_tokenId]; // 刪除order

        // 釋放Revoke事件
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    // 調整價格: 賣家調整掛單價格
    function update(
        address _nftAddr,
        uint256 _tokenId,
        uint256 _newPrice
    ) public {
        require(_newPrice > 0, "Invalid Price"); // NFT價格大於0
        Order storage _order = nftList[_nftAddr][_tokenId]; // 取得Order
        require(_order.owner == msg.sender, "Not Owner"); // 必須由持有人發起
        // 聲明IERC721介面合約變量
        IERC721 _nft = IERC721(_nftAddr);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合約中

        // 調整NFT價格
        _order.price = _newPrice;

        // 釋放Update事件
        emit Update(msg.sender, _nftAddr, _tokenId, _newPrice);
    }

    // 實現{IERC721Receiver}的onERC721Received，能夠接收ERC721代幣
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
