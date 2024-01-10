// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

contract donation {

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    struct Contributors {
        uint id;
        string name;
        uint256 amount;
        address sender_address;
    }

    uint256 id = 0;
    mapping(uint => Contributors) public contributor;

    function doDonation(string memory name) public payable {
        id += 1;
        contributor[id] = Contributors(id, name, msg.value, msg.sender);
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdrawMoney(address payable _to) public onlyOwner {
        _to.transfer(getBalance());
    }
}