// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract DonateV4 is Pausable, ReentrancyGuard {
  address private owner;
  mapping(address => uint256) private donations;
  uint256 private totalDonations;

  event DonationReceived(address indexed donor, uint256 amount);

  constructor() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Only the contract owner can call this function");
    _;
  }

  function donate() external payable whenNotPaused nonReentrant {
    require(msg.value > 0, "Donation amount must be greater than zero");

    donations[msg.sender] += msg.value;
    totalDonations += msg.value;

    emit DonationReceived(msg.sender, msg.value);
  }

  function getDonation(address donor) external view returns (uint256) {
    return donations[donor];
  }

  function getTotalDonations() external view returns (uint256) {
    return totalDonations;
  }

  function withdrawDonations() external onlyOwner {
    require(totalDonations > 0, "No donations to withdraw");

    uint256 amount = totalDonations;
    totalDonations = 0;

    (bool success, ) = owner.call{value: amount}("");
    require(success, "Failed to send donations to the owner");
  }

}
