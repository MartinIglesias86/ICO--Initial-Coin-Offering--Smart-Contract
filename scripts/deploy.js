const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });
const { CRYPTO_DEVS_NFT_CONTRACT_ADDRESS } = require("../constants");

async function main() {
  //address of the Crypto Devs NFT contract that you deployed
  const cryptoDevsNFTContract = CRYPTO_DEVS_NFT_CONTRACT_ADDRESS;
  /*
  A Contract Factory in ethers.js is an abstraction used to deploy new smart contracts,
  so cryptoDevsTokenContract here is a factory for instances of our CryptoDevToken contract
  */
  const cryptoDevsTokenContract = await ethers.getContractFactory("CryptoDevToken");
  //deploy the contract
  const deployedCryptoDevsTokenContract = await cryptoDevsTokenContract.deploy(cryptoDevsNFTContract);
  //print the address of the deployed contract
  console.log(
    "Crypto Devs Token Address: ",
    deployedCryptoDevsTokenContract.address
  );
}

//call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error((error));
    process.exit(1);
  });