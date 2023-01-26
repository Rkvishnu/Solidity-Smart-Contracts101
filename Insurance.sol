// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Insurance {
    address payable owner;

    address[] public policyHolders;
    //number of policies a person have taken
    mapping(address => uint) public policies;
    //number of claimed policies
    mapping(address => uint) public claims;

    uint public totalPremium;

    constructor() {
        owner = payable(msg.sender);
    }

    function purchasePolicy(uint premium) external payable {
        require(msg.value == premium, "Incorrect premium amount");
        require(premium > 0, "Invalid premium amount");

        //add in policcyHolders record array
        policyHolders.push(msg.sender);
        policies[msg.sender] = premium;
        totalPremium += premium;
    }

    function fileClaim(uint amount) external {
        require(policies[msg.sender] > 0, "Must have a valid policy to claim");
        require(amount > 0, "claimed amount must be greater than zero");
        require(amount <= policies[msg.sender], "not enough amount to claim");

        claims[msg.sender] += amount;
        // policies[msg.sender] -= amount;
    }

    function approveClaim(address policyHolder) external {
        require(msg.sender == owner, "only owner is allowed ");
        require(claims[policyHolder] > 0, "invalid claim");

        //send claimdAmount to policyHolder
        payable(policyHolder).transfer(claims[policyHolder]);
        claims[policyHolder] = 0;
    }

    //allow user to check their policy
    function getPolicy(address policyHolder) external view returns (uint) {
        return policies[policyHolder];
    }

    //allow user to check how much amount they have claimed
    function getClaimAmount(address policyHolder) external view returns (uint) {
        return claims[policyHolder];
    }

    //how much money the user have paid for premium
    function getTotalPremium() external view returns (uint) {
        return totalPremium;
    }

    //if owner wants to provide the access to someone else like  e.g.manager

    function grantAccess(address manager) public {
        require(
            msg.sender == owner,
            "only owner is allowed to grant the access"
        );
        owner = payable(manager);
    }

    
}
