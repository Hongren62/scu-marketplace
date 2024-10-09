import React, { useState, useEffect } from "react";
import "../styles/NFTList.css";

function NFTList({ web3, nftSwapContract, account }) {
  const [nfts, setNfts] = useState([]);

  useEffect(() => {
    const fetchNFTs = async () => {
      try {
        const listEvents = await nftSwapContract.getPastEvents("List", {
          fromBlock: 0,
          toBlock: "latest",
        });

        const nftList = await Promise.all(
          listEvents.map(async (event) => {
            const { seller, nftAddr, tokenId, price } = event.returnValues;
            console.log("Fetched tokenId:", tokenId);
            const order = await nftSwapContract.methods
              .nftList(nftAddr, tokenId)
              .call();
            if (order.price > 0) {
              return { seller, nftAddr, tokenId, price };
            }
            return null;
          })
        );

        setNfts(nftList.filter((nft) => nft !== null));
      } catch (error) {
        console.error("Error fetching NFTs:", error);
      }
    };

    if (web3 && nftSwapContract && account) {
      fetchNFTs();
    }
  }, [web3, nftSwapContract, account]);

  return (
    <div className="nft-list">
      <h2>Available NFTs</h2>
      <ul>
        {nfts.map((nft, index) => (
          <li key={index}>
            <p>
              <strong>NFT Address:</strong> {nft.nftAddr}
            </p>
            <p>
              <strong>Token ID:</strong> {nft.tokenId.toString()}
            </p>
            <p>
              <strong>Price:</strong> {web3.utils.fromWei(nft.price, "ether")}{" "}
              ETH
            </p>
          </li>
        ))}
      </ul>
    </div>
  );
}

export default NFTList;
