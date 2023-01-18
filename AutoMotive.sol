//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract AutoMotive {
    //variable
    address public owner;
    mapping(address => bool) public buyers;
    string public vehicleBrand;
    string public vehicleModel;
    uint256 public registrationNumber;
    uint256 public price;

    //events
    event Purchase(
        address buyer,
        string brand,
        string model,
        uint256 _regiNumber,
        uint256 price
    );

    constructor() {
        owner == msg.sender;
    }

    function setPrice(uint256 _price) public payable {
        require(msg.sender == owner);
        price = _price;
    }

    // function to buy Vehicle
    function buyVehicle(
        string memory _brand,
        string memory _model,
        uint256 _regiNumber
    ) public payable {
        require(msg.sender != owner);
        require(price >= 0);
        require(buyers[msg.sender] == false, "you are already owner");

        vehicleBrand = _brand;
        vehicleModel = _model;
        registrationNumber = _regiNumber;
        buyers[msg.sender] == true; //you are the owner now

        emit Purchase(msg.sender, _brand, _model, _regiNumber, msg.value);
    }

    //checking ownership

    function checkOwnership() public view returns (bool) {
        return buyers[msg.sender];
    }

    //trasnfer ownernship

    function transferOwnership(address recipient) public {
        require(msg.sender == owner, "Only owner ");
        require(recipient != owner, "Can not revoke acces from the contract ");
        owner = recipient;
    }
}
