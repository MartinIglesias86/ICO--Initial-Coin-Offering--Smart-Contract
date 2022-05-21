//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ICryptoDevs.sol";

contract CryptoDevToken is ERC20, Ownable {
    //price of one Crypto Dev Token
    uint256 public constant tokenPrice = 0.001 ether;
    /*
    Each NFT would give the user 10 tokens.
    It needs to be represented as 10 * (10 ** 18) as ERC20 tokens are represented by the smallest denomination possible for the token
    By default, ERC20 tokens have the samllest denomination of 10^(-18). This means, having a balance of (1)
    is actually equal to (10 ^ -18) tokens.
    Owning 1 full token is equivalent to owning (10^18) tokens when you account for the decimal places.
    */
    uint256 public constant tokensPerNFT = 10 * 10**18;
    //the max total supply is 20000 for Crypto Dev Tokens
    uint256 public constant maxTotalSupply = 20000 * 10**18;
    //CryptoDevsNFT contract instance
    ICryptoDevs CryptoDevsNFT;
    //mapping to keep track of which tokensIds have been claimed
    mapping(uint256 => bool) public tokenIdsClaimed;

    constructor(address _cryptoDevsContract) ERC20("Crypto Dev Token", "CD") {
        CryptoDevsNFT = ICryptoDevs(_cryptoDevsContract);
    }

    /*
    @dev Mints 'amount' number of CryptoDevTokens
    Requirements:
    - `msg.value` should be equal or grater than the tokenPrice * amount
    */
    function mint(uint256 amount) public payable {
        //the value of ether that should be equal or greater than tokenPrice * amount
        uint256 _requiredAmount = tokenPrice * amount;
        require(msg.value >= _requiredAmount, "La cantidad de Ether enviada es incorrecta");
        //total tokens + amount <= 20000, otherwise revert the transaction
        uint256 amountWithDecimals = amount * 10**18;
        require(
            (totalSupply() + amountWithDecimals) <= maxTotalSupply,
            "Excede el suministro total maximo disponible."
        );
        //call the internal function from Openzeppelin's ERC20 contract
        _mint(msg.sender, amountWithDecimals);
    }
    /*
    @dev Mints tokens based on the number of NFT's held by the sender
    Requirements:
    - balance of Crypto Dev NFT's owned by the sender should be greater than 0
    - tokens should have not been claimed for all the NFT's owned by the sender
    */
    function claim() public {
        address sender = msg.sender;
        //get the number of CryptoDev NFT's held by a given sender address
        uint256 balance = CryptoDevsNFT.balanceOf(sender);
        //if the balance is zero, revert the transaction
        require(balance > 0, "No posee ningun NFT de Crypto Dev");
        //amount keeps track of number of unclaimed tokenIds
        uint256 amount = 0;
        //loop over the balance and get the token ID owned by `sender` at a given `index` of it's token list
        for (uint256 i = 0; i < balance; i++) {
            uint256 tokenId = CryptoDevsNFT.tokenOfOwnerByIndex(sender, i);
            //if the tokenId has not been claimed, increase the amount
            if (!tokenIdsClaimed[tokenId]) {
                amount += 1;
                tokenIdsClaimed[tokenId] = true;
            }
        }
        //if all the token Ids have been claimed, revert the transaction
        require(amount > 0, "Ya has reclamado todos los tokens");
        //call the internal function from Openzeppelin's ERC20 contract
        //mint (amount*10) tokens for each NFT
        _mint(msg.sender, amount * tokensPerNFT);
    }
    //function to receive Ether. msg.data must be empty
    receive() external payable {}
    //fallback function is called when msg.data is not empty
    fallback() external payable {}
}