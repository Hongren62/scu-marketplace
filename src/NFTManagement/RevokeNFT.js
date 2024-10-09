import React, { useState } from "react";
import "../styles/RevokeNFT.css";

function RevokeNFT({ web3, nftSwapContract, account }) {
  const [nftAddr, setNftAddr] = useState("");
  const [tokenId, setTokenId] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const handleRevoke = async () => {
    if (!nftAddr || !tokenId) {
      setError("Please fill in all fields.");
      return;
    }

    setIsLoading(true);
    setError("");

    try {
      await nftSwapContract.methods
        .revoke(nftAddr, tokenId)
        .send({ from: account });
      alert("NFT listing revoked successfully!");
      setNftAddr("");
      setTokenId("");
    } catch (error) {
      console.error("Error revoking NFT listing:", error);
      setError(error.message || "Failed to revoke NFT listing");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="revoke-nft">
      <h2 className="revoke-heading">Revoke NFT Listing</h2>
      {error && <p className="revoke-error">{error}</p>}
      <div className="revoke-form-group">
        <input
          type="text"
          placeholder="NFT Contract Address"
          value={nftAddr}
          onChange={(e) => setNftAddr(e.target.value)}
          className="revoke-input"
        />
      </div>
      <div className="revoke-form-group">
        <input
          type="text"
          placeholder="Token ID"
          value={tokenId}
          onChange={(e) => setTokenId(e.target.value)}
          className="revoke-input"
        />
      </div>
      <button
        onClick={handleRevoke}
        className={`revoke-button ${isLoading ? "disabled" : ""}`}
        disabled={isLoading}
      >
        {isLoading ? "Revoking..." : "Revoke Listing"}
      </button>
    </div>
  );
}

export default RevokeNFT;
