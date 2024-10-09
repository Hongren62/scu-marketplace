import React, { useState } from "react";
import "../styles/BuyNFT.css";

function BuyNFT({ web3, nftSwapContract, account }) {
  const [nftAddr, setNftAddr] = useState("");
  const [tokenId, setTokenId] = useState("");
  const [price, setPrice] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const handleBuy = async () => {
    if (!nftAddr || !tokenId || !price) {
      setError("Please fill in all fields.");
      return;
    }

    if (isNaN(parseFloat(price)) || parseFloat(price) <= 0) {
      setError("Please enter a valid price.");
      return;
    }

    setIsLoading(true);
    setError("");

    try {
      await nftSwapContract.methods.purchase(nftAddr, tokenId).send({
        from: account,
        value: web3.utils.toWei(price, "ether"),
      });
      alert("NFT purchased successfully!");
      setNftAddr("");
      setTokenId("");
      setPrice("");
    } catch (error) {
      console.error("Error buying NFT:", error);
      setError(error.message || "Failed to purchase NFT");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="buy-nft">
      <h2 className="buy-heading">Buy NFT</h2>
      {error && <p className="buy-error">{error}</p>}
      <div className="buy-form-group">
        <input
          id="nftAddr"
          type="text"
          placeholder="NFT Contract Address"
          value={nftAddr}
          onChange={(e) => setNftAddr(e.target.value)}
          className="buy-input"
        />
      </div>
      <div className="buy-form-group">
        <input
          id="tokenId"
          type="text"
          placeholder="Token ID"
          value={tokenId}
          onChange={(e) => setTokenId(e.target.value)}
          className="buy-input"
        />
      </div>
      <div className="buy-form-group">
        <input
          id="price"
          type="text"
          placeholder="Price (ETH)"
          value={price}
          onChange={(e) => setPrice(e.target.value)}
          className="buy-input"
        />
      </div>
      <button
        onClick={handleBuy}
        className={`buy-button ${isLoading ? "disabled" : ""}`}
        disabled={isLoading}
      >
        {isLoading ? "Buying..." : "Buy NFT"}
      </button>
    </div>
  );
}

export default BuyNFT;
