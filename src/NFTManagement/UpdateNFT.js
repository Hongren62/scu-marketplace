import React, { useState } from "react";
import "../styles/UpdateNFT.css";

function UpdateNFT({ web3, nftSwapContract, account }) {
  const [nftAddr, setNftAddr] = useState("");
  const [tokenId, setTokenId] = useState("");
  const [newPrice, setNewPrice] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const handleUpdate = async () => {
    if (!nftAddr || !tokenId || !newPrice) {
      setError("Please fill in all fields.");
      return;
    }

    if (isNaN(parseFloat(newPrice)) || parseFloat(newPrice) <= 0) {
      setError("Please enter a valid price.");
      return;
    }

    setIsLoading(true);
    setError("");

    try {
      const newPriceWei = web3.utils.toWei(newPrice, "ether");
      await nftSwapContract.methods
        .update(nftAddr, tokenId, newPriceWei)
        .send({ from: account });
      alert("NFT price updated successfully!");
      setNftAddr("");
      setTokenId("");
      setNewPrice("");
    } catch (error) {
      console.error("Error updating NFT price:", error);
      setError(error.message || "Failed to update NFT price");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="update-nft">
      <h2 className="update-heading">Update NFT Price</h2>
      {error && <p className="update-error">{error}</p>}
      <div className="update-form-group">
        <input
          id="nftAddr"
          type="text"
          placeholder="NFT Contract Address"
          value={nftAddr}
          onChange={(e) => setNftAddr(e.target.value)}
          className="update-input"
        />
      </div>
      <div className="update-form-group">
        <input
          id="tokenId"
          type="text"
          placeholder="Token ID"
          value={tokenId}
          onChange={(e) => setTokenId(e.target.value)}
          className="update-input"
        />
      </div>
      <div className="update-form-group">
        <input
          id="newPrice"
          type="text"
          placeholder="New Price (ETH)"
          value={newPrice}
          onChange={(e) => setNewPrice(e.target.value)}
          className="update-input"
        />
      </div>
      <button
        onClick={handleUpdate}
        className={`update-button ${isLoading ? "disabled" : ""}`}
        disabled={isLoading}
      >
        {isLoading ? "Updating..." : "Update Price"}
      </button>
    </div>
  );
}

export default UpdateNFT;
