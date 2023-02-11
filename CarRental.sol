pragma solidity ^0.8.0;

contract VehicleRental {
    //rental info
    struct Rental {
        address renter;
        uint rentalPeriod;
        uint rentalPrice;
        bool damage;
        bool paid;
    }

    //vehicle info
    struct Vehicle {
        string make;
        string model;
        uint year;
        uint dailyPrice;
        Rental currentRental;
        Rental[] rentalHistory;
    }

    Vehicle[] VehicleRecord;
    mapping(uint => Vehicle) public vehicles;
    mapping(uint => bool) public operationRecords;

    uint public vehicleCount;
    uint public rentalCount;
    uint public revenue;

    event NewRental(
        address renter,
        uint rentalPeriod,
        uint rentalPrice,
        uint vehicleId
    );
    event DamageReport(uint rentalId, bool damage);

    //add New  Vehicle
    function addVehicle(
        string memory make,
        string memory model,
        uint year,
        uint dailyPrice
    ) public {
        vehicles[vehicleCount] = Vehicle(
            make,
            model,
            year,
            dailyPrice,
            Rental(address(0), 0, 0, false, false),
            new Rental[](0)
        );
        vehicleCount++;
    }

    function rentVehicle(uint vehicleId, uint rentalPeriod) public payable {
        require(
            msg.value == vehicles[vehicleId].dailyPrice * rentalPeriod,
            "Insufficient payment"
        );

        //curently rented  person infomation
        vehicles[vehicleId].currentRental = Rental(
            msg.sender,
            rentalPeriod,
            msg.value,
            false,
            false
        );
        revenue += msg.value;
        emit NewRental(msg.sender, rentalPeriod, msg.value, vehicleId);
        rentalCount++;
    }

    //check if there any damage on vehicle
    function checkDamage(uint rentalId, bool damage) public {
        Rental storage rental = vehicles[rentalId].currentRental;
        rental.damage = damage;
        emit DamageReport(rentalId, damage);
    }

    function getRentalRecord(
        uint rentalId
    ) public view returns (address, uint, uint, bool, bool) {
        Rental memory rental = vehicles[rentalId].currentRental;
        return (
            rental.renter,
            rental.rentalPeriod,
            rental.rentalPrice,
            rental.damage,
            rental.paid
        );
    }

    //get past rental record/history  of the vehicle
    function getPastRentalRecord(
        uint vehicleId,
        uint rentalId
    ) public view returns (address, uint, uint, bool, bool) {
        Rental memory rental = vehicles[vehicleId].rentalHistory[rentalId];
        return (
            rental.renter,
            rental.rentalPeriod,
            rental.rentalPrice,
            rental.damage,
            rental.paid
        );
    }

    //total revenue generated
    function getRevenueReport() public view returns (uint) {
        return revenue;
    }

    function getVehicleInfo() public view returns (Vehicle[] memory) {
        // Vehicle memory vehicle = vehicles[vehicleId];
        // return (vehicle.make, vehicle.model, vehicle.year, vehicle.dailyPrice);
        return VehicleRecord;
    }

    function payRental(uint rentalId) public {
        Rental storage rental = vehicles[rentalId].currentRental;
        require(rental.renter == msg.sender, "Unauthorized payment");
        require(
            rental.damage == false,
            "Payment not allowed with damage report"
        );
        require(rental.paid == false, "Payment already made");
        rental.paid = true;
        vehicles[rentalId].rentalHistory.push(rental);
        vehicles[rentalId].currentRental = Rental(
            address(0),
            0,
            0,
            false,
            false
        );
    }
}
