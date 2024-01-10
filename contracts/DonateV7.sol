//SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Donation is Ownable {
  using Counters for Counters.Counter;

  struct Donater {
    address donaterAddress;
    uint256 donationAmount;
  }

  mapping(address => Donater) private donaters;
  mapping(uint256 => address) private donatersIndex;
  Counters.Counter private donationsCounter;

  receive() external payable {
    if (donaters[msg.sender].donaterAddress == msg.sender) {
      donaters[msg.sender].donationAmount =
        donaters[msg.sender].donationAmount +
        msg.value;
    } else {
      donaters[msg.sender].donationAmount = msg.value;
      donaters[msg.sender].donaterAddress = msg.sender;

      donatersIndex[donationsCounter.current()] = msg.sender;
      donationsCounter.increment();
    }
  }

  function getDonationByAddress(address _from)
    public
    view
    onlyOwner
    returns (uint256)
  {
    return donaters[_from].donationAmount;
  }

  function getAllDonaters() public view onlyOwner returns (Donater[] memory) {
    uint256 donationCount = donationsCounter.current();
    Donater[] memory allDonaters = new Donater[](donationCount);

    for (uint256 i = 0; i < donationCount; i++) {
      allDonaters[i] = donaters[donatersIndex[i]];
    }

    return allDonaters;
  }

  function getBalance() public view onlyOwner returns (uint256) {
    return address(this).balance;
  }

  function sendDonations(address payable _to, uint256 _amount)
    public
    payable
    onlyOwner
  {
    _to.transfer(_amount);
  }
}