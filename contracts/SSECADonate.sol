// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract DonateContract is Ownable, ReentrancyGuard, Pausable {
    using Address for address;

    uint totalDonations; // the amount of donations
    mapping(address => bool) allowedTokens; // whitelist of allowed tokens
    bool public donationsEnabled; // flag to enable/disable donations

    event Donation(address indexed donor, uint amount);
    event Withdrawal(address indexed recipient, uint amount);
    event DonationsDisabled();
    event DonationsEnabled();

    //contract settings
    constructor() {
        allowedTokens[address(0)] = true; // Ether is allowed
        allowedTokens[
            address(0x0000000000000000000000000000000000001010)
        ] = true; // Matic is allowed
        donationsEnabled = true; // donations are enabled by default
    }

    //public function to make donate with ether on Ethereum blockchain
    function donate() public payable whenNotPaused nonReentrant {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(
            !msg.sender.isContract(),
            "Smart contracts are not allowed to donate"
        );
        require(allowedTokens[address(0)], "Ether donations are not allowed");
        require(donationsEnabled, "Donations are currently disabled");
        totalDonations += msg.value;
        emit Donation(msg.sender, msg.value);
    }

    //public function to make donate with Matic on Polygon blockchain
    function donateMatic() public payable whenNotPaused nonReentrant {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(
            !msg.sender.isContract(),
            "Smart contracts are not allowed to donate"
        );
        require(
            allowedTokens[address(0x0000000000000000000000000000000000001010)],
            "Matic donations are not allowed"
        );
        require(donationsEnabled, "Donations are currently disabled");
        totalDonations += msg.value;
        emit Donation(msg.sender, msg.value);
    }

    // public function to return total of donations
    function getTotalDonations() public view returns (uint) {
        return totalDonations;
    }

    // public function to withdraw contract balance
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Contract balance is 0");
        require(owner() != address(0), "Owner address cannot be 0");
        uint amount = address(this).balance;
        require(amount > 0, "Withdrawal amount must be greater than 0");
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Failed to send money");
        emit Withdrawal(owner(), amount);
    }

    // public function to disable donations in emergency
    function disableDonations() public onlyOwner {
        require(donationsEnabled, "Donations are already disabled");
        donationsEnabled = false;

        _pause();

        emit DonationsDisabled();
    }

    // public function to enable donations after emergency
    function enableDonations() public onlyOwner {
        require(!donationsEnabled, "Donations are already enabled");
        donationsEnabled = true;

        _unpause();

        emit DonationsEnabled();
    }
}
