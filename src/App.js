import React, { useState } from "react";
import WalletConnect from "./WalletConnect/WalletConnect";
import NFTList from "./NFTManagement/NFTList";
import ListNFT from "./NFTManagement/ListNFT";
import RevokeNFT from "./NFTManagement/RevokeNFT";
import UpdateNFT from "./NFTManagement/UpdateNFT";
import BuyNFT from "./NFTManagement/BuyNFT";
import NFTSwapABI from "./NFTSwapABI.json";
import "./styles/App.css";

function App() {
  const [web3, setWeb3] = useState(null);
  const [account, setAccount] = useState(null);
  const [nftSwapContract, setNftSwapContract] = useState(null);

  const handleConnect = async (web3Instance, connectedAccount) => {
    setWeb3(web3Instance);
    setAccount(connectedAccount);

    const contractAddress = "0xECdeAaD85A695CEb83d5d9e00c0D3160220773A7";
    const contract = new web3Instance.eth.Contract(NFTSwapABI, contractAddress);
    setNftSwapContract(contract);
  };

  return (
    <div className="App">
      <header className="App-header">
        <h1>SCU Marketplace</h1>
        <WalletConnect onConnect={handleConnect} />
      </header>
      {web3 && account && nftSwapContract && (
        <div className="components-container">
          <div className="component">
            <NFTList
              web3={web3}
              nftSwapContract={nftSwapContract}
              account={account}
            />
          </div>
          <div className="component">
            <ListNFT
              web3={web3}
              nftSwapContract={nftSwapContract}
              account={account}
            />
          </div>
          <div className="component">
            <RevokeNFT
              web3={web3}
              nftSwapContract={nftSwapContract}
              account={account}
            />
          </div>
          <div className="component">
            <UpdateNFT
              web3={web3}
              nftSwapContract={nftSwapContract}
              account={account}
            />
          </div>
          <div className="component">
            <BuyNFT
              web3={web3}
              nftSwapContract={nftSwapContract}
              account={account}
            />
          </div>
        </div>
      )}
    </div>
  );
}

export default App;
