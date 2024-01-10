// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DonateV3 is ReentrancyGuard, Pausable, Ownable {
  mapping(address => uint256) private donations;
  address[] private donators;

  event DonationReceived(address indexed donor, uint256 amount);
  event Withdrawal(uint256 amount);

  constructor(address initialOwner) Ownable(initialOwner) {
    _transferOwnership(initialOwner);
  }

  function donate() external payable whenNotPaused nonReentrant {
    require(msg.value > 0, "Donation amount must be greater than zero");
    if (donations[msg.sender] == 0) {
      donators.push(msg.sender);
    }
    donations[msg.sender] += msg.value;
    emit DonationReceived(msg.sender, msg.value);
  }

  function getDonation(address donor) external view returns (uint256) {
    return donations[donor];
  }

  function getAllDonators() external view returns (address[] memory) {
    return donators;
  }

  function getTotalDonations() external view returns (uint256) {
    uint256 total = 0;
    for (uint256 i = 0; i < donators.length; i++) {
      total += donations[donators[i]];
    }
    return total;
  }

  function withdraw() external onlyOwner {
    require(owner() != address(0), "Invalid owner address");
    uint256 balance = address(this).balance;
    require(balance > 0, "No funds to withdraw");
    (bool success, ) = owner().call{value: balance}("");
    require(success, "Transfer failed");
    emit Withdrawal(balance);
  }
}