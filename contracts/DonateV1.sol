// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

interface IDonate {
    function donate() external payable;

    function withdraw() external;

    function getDonation(address donor) external view returns (uint256);
}

contract Donate is Ownable, ReentrancyGuard, Pausable, IDonate {
    mapping(address => uint256) private donations;
    uint256 private totalDonations;

    event DonationReceived(address indexed donor, uint256 amount);

    constructor() {
        // Set the contract owner
        transferOwnership(msg.sender);
    }

    function donate() external payable whenNotPaused nonReentrant {
        require(msg.value > 0, "Donation amount must be greater than zero");
        donations[msg.sender] += msg.value;
        totalDonations += msg.value;
        emit DonationReceived(msg.sender, msg.value);
    }

    function withdraw() external onlyOwner whenNotPaused {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds available for withdrawal");
        payable(owner()).transfer(balance);
    }

    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner(),
            "Only the contract owner can call this function"
        );
        _;
    }

    modifier whenNotPaused() {
        require(!paused(), "Contract is paused");
        _;
    }
}
