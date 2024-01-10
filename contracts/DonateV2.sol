// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DonateV2 is Pausable, ReentrancyGuard, Ownable {
  uint256 public totalDonations;
  mapping(address => uint256) public donations;

  event DonationReceived(address indexed donator, uint256 amount);
  event DonationWithdrawn(address indexed donator, uint256 amount);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() {
    _transferOwnership(_msgSender());
  }

  function donate() external payable whenNotPaused nonReentrant {
    require(msg.value > 0, "Donation amount must be greater than zero");

    donations[_msgSender()] += msg.value;
    totalDonations += msg.value;

    emit DonationReceived(_msgSender(), msg.value);
  }

  function getDonation(address donator) external view returns (uint256) {
    return donations[donator];
  }

  function getTotalDonations() external view returns (uint256) {
    return totalDonations;
  }

  function withdrawDonations() external whenNotPaused nonReentrant onlyOwner {
    require(address(this).balance > 0, "No donations to withdraw");
    require(owner() != address(0), "Owner address cannot be the zero address");

    uint256 balance = address(this).balance;
    (bool success, ) = _msgSender().call{value: balance}("");
    require(success, "Transfer failed");

    emit DonationWithdrawn(owner(), balance);
  }

  function pause() public onlyOwner {
    _pause();
  }

  function unpause() public onlyOwner {
    _unpause();
  }

  // Override the function to change the owner.
  function transferOwnership(address newOwner) public virtual onlyOwner {
    require(newOwner != address(0), "New owner cannot be the zero address");
    require(owner() != address(0), "Owner address cannot be the zero address");

    emit OwnershipTransferred(owner(), newOwner);
    _transferOwnership(newOwner);
  }
}