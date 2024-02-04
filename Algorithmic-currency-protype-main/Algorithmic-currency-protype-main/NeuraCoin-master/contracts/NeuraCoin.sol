// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract NeuraCoinOracle is ChainlinkClient {
    address public oracle;
    bytes32 public jobId;
    uint256 public fee;

    uint256 public accuracyData; // Store the fetched accuracy data

    constructor() {
        setPublicChainlinkToken();
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8; // Chainlink Ethereum Kovan Testnet Oracle
        jobId = "d5270d1c311941d0adad91e22b0f4b2e";
        fee = 0.1 * 10**18; // 0.1 LINK
    }

    function requestAccuracyData() public {
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);
        req.add("get", "YOUR_API_ENDPOINT"); // Replace with your API endpoint
        req.add("path", "data"); // Replace with the JSON path to your data
        sendChainlinkRequestTo(oracle, req, fee);
    }

    function fulfill(bytes32 _requestId, uint256 _accuracyData) public recordChainlinkFulfillment(_requestId) {
        accuracyData = _accuracyData;
        // Now you have the accuracy data, you can process it further within your smart contract
    }
}
// To create a block reward
// Block reward function with (before token transfer and _mintMinerReward)

contract NeuraCoin is ERC20Capped, ERC20Burnable {
    address payable public owner;
    uint256 public blockReward;
    uint8 public burnPercentage; // Percentage of tokens to burn during transfers
    uint256 public basePrice; // Initial base price of the coin
    uint256 public currentPrice; // Current adjusted price based on accuracy

    constructor(uint256 cap, uint256 reward, uint8 _burnPercentage, uint256 _basePrice) ERC20("NeuraCoin", "NEU") ERC20Capped(cap * (10**18)) {
        owner = payable(msg.sender);
        _mint(owner, 7000000 * (10**18));
        blockReward = reward * (10**18);
        burnPercentage = _burnPercentage;
        basePrice = _basePrice * (10**18);
        currentPrice = basePrice;
    }

    function adjustPriceBasedOnAccuracy(uint256 accuracy) public onlyOwner {
        // Example: Adjust the price linearly based on accuracy
        // You can customize this logic based on your specific requirements
        require(accuracy <= 100, "Invalid accuracy value");

        // Adjust the price linearly based on accuracy (decrease by 1% for each 1% decrease in accuracy)
        currentPrice = (basePrice * accuracy) / 100;
    }

    function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override {
        super._beforeTokenTransfer(from, to, value);
        if (from != address(0) && to != block.coinbase && block.coinbase != address(0)) {
            _mintMinerReward();
        }

        // Burn a percentage of tokens during transfers
        if (burnPercentage > 0 && from != address(0) && to != address(0)) {
            uint256 burnAmount = (value * burnPercentage) / 100;
            _burn(from, burnAmount);
        }
    }

    function _mintMinerReward() internal {
        _mint(block.coinbase, blockReward);
    }

    function setBlockReward(uint256 reward) public onlyOwner {
        blockReward = reward * (10**18);
    }

    function setBurnPercentage(uint8 percentage) public onlyOwner {
        require(percentage <= 100, "Invalid burn percentage");
        burnPercentage = percentage;
    }

    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }
}