import React, { useState } from "react";
import "../styles/ListNFT.css";

function ListNFT({ web3, nftSwapContract, account }) {
  const [nftAddr, setNftAddr] = useState("");
  const [tokenId, setTokenId] = useState("");
  const [price, setPrice] = useState("");

  const handleList = async () => {
    try {
      const priceWei = web3.utils.toWei(price, "ether");
      await nftSwapContract.methods
        .list(nftAddr, tokenId, priceWei)
        .send({ from: account });
      alert("NFT listed successfully!");
    } catch (error) {
      console.error("Error listing NFT:", error);
      alert("Failed to list NFT");
    }
  };

  return (
    <div className="list-nft">
      <h2>List NFT</h2>
      <input
        type="text"
        placeholder="NFT Contract Address"
        value={nftAddr}
        onChange={(e) => setNftAddr(e.target.value)}
      />
      <input
        type="text"
        placeholder="Token ID"
        value={tokenId}
        onChange={(e) => setTokenId(e.target.value)}
      />
      <input
        type="text"
        placeholder="Price (ETH)"
        value={price}
        onChange={(e) => setPrice(e.target.value)}
      />
      <button onClick={handleList}>List NFT</button>
    </div>
  );
}

export default ListNFT;
