import React, { useState, useEffect } from "react";
import { Alert, AlertDescription, AlertTitle } from "./alert";
import "./styles/NFTMarketplace.css";

const NFTMarketplace = ({ web3, nftSwapContract, account }) => {
  const [nftAddr, setNftAddr] = useState("");
  const [tokenId, setTokenId] = useState("");
  const [price, setPrice] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");
  const [showApprovalAlert, setShowApprovalAlert] = useState(false);
  const [listings, setListings] = useState([]);
  const [collectionApprovals, setCollectionApprovals] = useState({});

  useEffect(() => {
    fetchListings();
    fetchCollectionApprovals();
  }, [nftSwapContract, account]);

  const fetchListings = async () => {
    try {
      const listEvents = await nftSwapContract.getPastEvents("List", {
        fromBlock: 0,
        toBlock: "latest",
      });

      const delistEvents = await nftSwapContract.getPastEvents("Revoke", {
        fromBlock: 0,
        toBlock: "latest",
      });

      const currentListings = await Promise.all(
        listEvents.map(async (event) => {
          const { seller, nftAddr, tokenId, price } = event.returnValues;
          const isDelisted = delistEvents.some(
            (e) =>
              e.returnValues.nftAddr === nftAddr &&
              e.returnValues.tokenId === tokenId
          );
          if (!isDelisted) {
            const order = await nftSwapContract.methods
              .nftList(nftAddr, tokenId)
              .call();
            if (order.price > 0) {
              return {
                seller,
                nftAddr,
                tokenId,
                price: web3.utils.fromWei(price, "ether"),
              };
            }
          }
          return null;
        })
      );

      setListings(currentListings.filter((listing) => listing !== null));
    } catch (error) {
      console.error("Error fetching listings:", error);
      setError("Failed to fetch listings");
    }
  };

  const fetchCollectionApprovals = async () => {
    try {
      const nftAddresses = [
        ...new Set(listings.map((listing) => listing.nftAddr)),
      ];
      const approvals = await Promise.all(
        nftAddresses.map(async (addr) => {
          const isApproved = await nftSwapContract.methods
            .isApprovedForAll(account, nftSwapContract._address)
            .call({ from: account });
          return [addr, isApproved];
        })
      );
      setCollectionApprovals(Object.fromEntries(approvals));
    } catch (error) {
      console.error("Error fetching collection approvals:", error);
    }
  };

  const checkAndRequestApproval = async () => {
    if (collectionApprovals[nftAddr]) {
      return;
    }

    setShowApprovalAlert(true);
    try {
      const nftContract = new web3.eth.Contract(
        [
          {
            constant: false,
            inputs: [
              { name: "operator", type: "address" },
              { name: "approved", type: "bool" },
            ],
            name: "setApprovalForAll",
            outputs: [],
            type: "function",
          },
        ],
        nftAddr
      );

      await nftContract.methods
        .setApprovalForAll(nftSwapContract._address, true)
        .send({ from: account });
      setCollectionApprovals((prev) => ({ ...prev, [nftAddr]: true }));
    } catch (error) {
      console.error("Error setting approval:", error);
      setError("Failed to set approval for the collection");
    } finally {
      setShowApprovalAlert(false);
    }
  };

  const handleList = async () => {
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
      // First, check if the contract has approval
      const nftContract = new web3.eth.Contract(
        [
          {
            inputs: [
              { internalType: "uint256", name: "tokenId", type: "uint256" },
            ],
            name: "getApproved",
            outputs: [{ internalType: "address", name: "", type: "address" }],
            stateMutability: "view",
            type: "function",
          },
        ],
        nftAddr
      );

      // tokenId有問題，先pass

      // const approvedAddress = await nftContract.methods
      //   .getApproved(tokenId)
      //   .call();

      // if (approvedAddress !== nftSwapContract._address) {
      //   setError("Please approve the NFT for trading first");
      //   setIsLoading(false);
      //   return;
      // }

      await checkAndRequestApproval();

      // Convert price from ETH to Wei
      const priceInWei = web3.utils.toWei(price.toString(), "ether");

      console.log("Listing parameters:", {
        nftAddr,
        tokenId,
        priceInWei,
      });

      await nftSwapContract.methods
        .list(nftAddr, tokenId, priceInWei)
        .send({ from: account });

      setNftAddr("");
      setTokenId("");
      setPrice("");
      alert("NFT listed successfully!");
    } catch (error) {
      console.error("Error listing NFT:", error);
      setError(error.message || "Failed to list NFT");
    } finally {
      setIsLoading(false);
    }
  };

  const handlePriceChange = (e) => {
    const value = e.target.value;
    if (value === "" || /^\d*\.?\d*$/.test(value)) {
      setPrice(value);
      setError("");
    }
  };

  const handleBuy = async (nftAddr, tokenId, price) => {
    setIsLoading(true);
    setError("");
    try {
      await nftSwapContract.methods.purchase(nftAddr, tokenId).send({
        from: account,
        value: web3.utils.toWei(price, "ether"),
      });
      alert("NFT purchased successfully!");
      fetchListings();
    } catch (error) {
      console.error("Error buying NFT:", error);
      setError(error.message || "Failed to purchase NFT");
    } finally {
      setIsLoading(false);
    }
  };

  const handleUpdate = async (nftAddr, tokenId, newPrice) => {
    setIsLoading(true);
    setError("");
    try {
      const newPriceWei = web3.utils.toWei(newPrice, "ether");
      await nftSwapContract.methods
        .update(nftAddr, tokenId, newPriceWei)
        .send({ from: account });
      alert("NFT price updated successfully!");
      fetchListings();
    } catch (error) {
      console.error("Error updating NFT price:", error);
      setError(error.message || "Failed to update NFT price");
    } finally {
      setIsLoading(false);
    }
  };

  const handleRevoke = async (nftAddr, tokenId) => {
    setIsLoading(true);
    setError("");
    try {
      await nftSwapContract.methods
        .revoke(nftAddr, tokenId)
        .send({ from: account });
      alert("NFT listing revoked successfully!");
      fetchListings();
    } catch (error) {
      console.error("Error revoking NFT listing:", error);
      setError(error.message || "Failed to revoke NFT listing");
    } finally {
      setIsLoading(false);
    }
  };

  const handleRevokeAll = async (nftAddr) => {
    setIsLoading(true);
    setError("");
    try {
      const userListings = listings.filter(
        (listing) => listing.nftAddr === nftAddr && listing.seller === account
      );
      for (const listing of userListings) {
        await nftSwapContract.methods
          .revoke(listing.nftAddr, listing.tokenId)
          .send({ from: account });
      }
      alert("All NFT listings for this collection revoked successfully!");
      fetchListings();
    } catch (error) {
      console.error("Error revoking all NFT listings:", error);
      setError(error.message || "Failed to revoke all NFT listings");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="nft-marketplace">
      <h2>NFT Marketplace</h2>
      {showApprovalAlert && (
        <Alert>
          <AlertTitle>Approval Required</AlertTitle>
          <AlertDescription>
            Approving NFT contract to manage your tokens. Please confirm the
            transaction.
          </AlertDescription>
        </Alert>
      )}
      {error && <p className="error">{error}</p>}

      <div className="list-nft">
        <h3>List NFT</h3>
        {error && <p className="list-error">{error}</p>}
        <div className="list-form-group">
          <input
            type="text"
            placeholder="NFT Contract Address"
            value={nftAddr}
            onChange={(e) => {
              setNftAddr(e.target.value);
              setError("");
            }}
            className="list-input"
          />
        </div>
        <div className="list-form-group">
          <input
            type="text"
            placeholder="Token ID"
            value={tokenId}
            onChange={(e) => {
              setTokenId(e.target.value);
              setError("");
            }}
            className="list-input"
          />
        </div>
        <div className="list-form-group">
          <input
            type="text"
            placeholder="Price (ETH)"
            value={price}
            onChange={handlePriceChange}
            className="list-input"
          />
        </div>
        <button
          onClick={handleList}
          className={`list-button ${isLoading ? "disabled" : ""}`}
          disabled={isLoading}
        >
          {isLoading ? "Listing..." : "List NFT"}
        </button>
      </div>

      <h3>Collection Approvals</h3>
      {Object.entries(collectionApprovals).map(([nftAddr, approved]) => (
        <div key={nftAddr}>
          <p>NFT Address: {nftAddr}</p>
          <p>Approved: {approved ? "Yes" : "No"}</p>
          <button onClick={() => checkAndRequestApproval(nftAddr, !approved)}>
            {approved ? "Revoke Approval" : "Grant Approval"}
          </button>
          {approved && (
            <button onClick={() => handleRevokeAll(nftAddr)}>
              Revoke All Listings
            </button>
          )}
        </div>
      ))}

      <h3>Current Listings</h3>
      <ul>
        {listings.map((listing, index) => (
          <li key={index}>
            <p>NFT Address: {listing.nftAddr}</p>
            <p>Token ID: {listing.tokenId}</p>
            <p>Current Price: {listing.price} ETH</p>
            {listing.seller.toLowerCase() === account.toLowerCase() ? (
              <>
                <input
                  type="number"
                  step="0.000001"
                  placeholder="New Price (ETH)"
                  onChange={(e) => {
                    const newListings = [...listings];
                    newListings[index].newPrice = e.target.value;
                    setListings(newListings);
                  }}
                />
                <button
                  onClick={() =>
                    handleUpdate(
                      listing.nftAddr,
                      listing.tokenId,
                      listing.newPrice
                    )
                  }
                >
                  Update Price
                </button>
                <button
                  onClick={() => handleRevoke(listing.nftAddr, listing.tokenId)}
                >
                  Revoke Listing
                </button>
              </>
            ) : (
              <button
                onClick={() =>
                  handleBuy(listing.nftAddr, listing.tokenId, listing.price)
                }
              >
                Buy NFT
              </button>
            )}
          </li>
        ))}
      </ul>
    </div>
  );
};

export default NFTMarketplace;
