//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Banking {
    address payable owner;
    // deposit
    // withdraw
    // trnafer
    mapping(address => uint256) public balances;

    constructor() {
        owner = payable(msg.sender);
    }

    function deposit() public payable {
        require(msg.value > 0, "Balance can not be zero");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(msg.sender == owner, "only owner of the account can withdraw");
        require(amount < balances[msg.sender], "Insufficient funds in account");
        require(amount > 0, "Insert valid amount");
        payable(msg.sender).transfer(amount);
        balances[msg.sender] -= amount;
    }

    //function to trnafer amount
    function transfer(address payable recipient, uint256 amount) public {
        require(amount <= balances[msg.sender], "Insufficient funds");
        require(amount > 0, "amount shoud be greater than zero");

        balances[msg.sender] -= amount;
        balances[recipient] += amount;
    }

    //return balance of specific account
    function getBalance(
        address payable userAccount
    ) public view returns (uint256) {
        return balances[userAccount];
    }

    //function to give permission to someone to use your fund on behalf of you
    function grantAccess(address payable user) public {
        require(msg.sender == owner, "only owner can grant the access");
        owner = user;
    }

    //remove access from the user
    function revokeAccess(address payable user) public {
        require(msg.sender == owner, "Only owner can revoke the access");
        require(user != owner, "Can not revoke acces from the contract ");
        owner = payable(msg.sender);
    }

    //desroy whole contract

    function destroy() public {
        require(msg.sender == owner, "Only owner can destroy the contract");
        selfdestruct(owner);
    }
}
