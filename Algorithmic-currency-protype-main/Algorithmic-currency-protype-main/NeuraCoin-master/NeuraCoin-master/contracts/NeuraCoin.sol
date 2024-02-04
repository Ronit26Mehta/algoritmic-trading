// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol"; // Maximum Supply
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol"; // Making Burnable 
 
// to create a block reward
// block reward function with ( _beforetokentransfer_ and _mintMinerreward)

contract NeuraCoin is ERC20Capped , ERC20Burnable {
    address payable public owner;
    uint256 public blockReward ;


   constructor(uint256 cap, uint256 reward) ERC20("NeuraCoin", "NEU") ERC20Capped(cap * (10 ** decimals())) {
    owner = payable(msg.sender);
    _mint(owner, 7000000 * (10 ** decimals()));
    blockReward = reward * (10 ** decimals());
    }
    /**
    function _mint( address account , uint256 amount) internal virtual override ( ERC20Capped , ERC20){
        require( ERC20.totalSupply() + amount <= cap() , " ERC20Capped : Cap Exceeded ");
        super._mint(account , amount);
    }

**/
    function _update(address from, address to, uint256 value) internal virtual override(ERC20, ERC20Capped) {
        super._update(from, to, value);

            if (from == address(0)) {
            uint256 maxSupply = cap();
            uint256 supply = totalSupply();
            if (supply > maxSupply) {
                revert ERC20ExceededCap(supply, maxSupply);
            }
        }
    }

    function _mintMinerReward() internal {
        _mint(block.coinbase , blockReward );
    }

  /** function _beforeTokenTransfer(address from, address to, uint256 value) internal virtual override{
    super._beforeTokenTransfer(from, to, value);
    if (from != address(0) && to != block.coinbase && block.coinbase != address(0)) {
        _mintMinerReward();
    } 
  }**/


    function setBlockReward(uint256 reward) public OnlyOwner {
        blockReward = reward * (10 ** decimals());
    }

    function destroy() public OnlyOwner {
        selfdestruct(owner); 
    }

   modifier OnlyOwner() {
    require(msg.sender == owner, "Not the contract owner");
    _;
    }
}
