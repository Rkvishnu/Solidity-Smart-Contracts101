//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Travel {
    address public owner;
    // Variables to store the available trips, their details and the booked status
    struct Trip {
        address customer;
        string destination;
        uint256 departureDate;
        uint256 returnDate;
        uint256 price;
        bool booked;
    }
    Trip[] public trips;

    // Events to emit when a trip is booked or a refund is processed
    event TripBooked(address indexed customer, uint256 tripId);
    event RefundProcessed(
        address indexed customer,
        uint256 tripId,
        uint256 refundAmount
    );

    // Function to add a new trip to the contract
    function addTrip(
        address customerAddr,
        string memory destination,
        uint256 departureDate,
        uint256 returnDate,
        uint256 price
    ) public {
        // trips.push(Trip(destination, departureDate, returnDate, false));
        Trip memory newTrip = Trip(
            customerAddr,
            destination,
            departureDate,
            returnDate,
            price,
            false
        );

        trips.push(newTrip);
    }

    // Function to book a trip
    function bookTrip(uint256 tripId) public payable {
        require(tripId < trips.length, "Invalid trip id");
        require(!trips[tripId].booked, "Trip already booked");
        require(msg.value >= 1000, "Insufficient funds");
        require(msg.value >= trips[tripId].price);
        //customer--> owner
        payable(trips[tripId].customer).transfer(trips[tripId].price);

        trips[tripId].booked = true;
        emit TripBooked(msg.sender, tripId);
    }

    // Function to view the details of a package
    function viewBooking() public view returns (Trip[] memory) {
        return trips;
    }
 

    // Function to process a refund
    function processRefund(uint256 tripId) public payable {
        require(tripId < trips.length, "Invalid trip id");
        require(trips[tripId].booked, "Trip not booked");

        //you will get only 50% as refund
        uint256 refundAmount = msg.value / 2;
        payable(msg.sender).transfer(refundAmount);
        emit RefundProcessed(msg.sender, tripId, refundAmount);
    }
}
