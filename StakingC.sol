//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

contract Staking {
    address public owner;

    struct Position {
        uint positionId;
        address walletAddress;
        uint createdDate;
        uint unlockDate;
        uint percentInterest;
        uint weiStacked;
        uint weiInterest;
        bool open;
    }

    Position position;

    uint public currentPositionId; // will be incremented afetr every new position created

    mapping(uint => Position) public positions;
    //user can see all the positions by address
    mapping(address => uint[]) public positionIdsByAddress;
    mapping(uint => uint) public tiers;
    uint[] public lockPeriods; //30days,60days and 180days

    constructor() payable {
        owner = msg.sender;
        currentPositionId = 0;

        tiers[30] = 700; //7%
        tiers[90] = 1000;//10%
        tiers[180] = 1200;//12%

        lockPeriods.push(30);
        lockPeriods.push(90);
        lockPeriods.push(180);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    //function to stakeEthers
    function stakeEthers(uint numDays) external payable{
        require(tiers[numDays] > 0, "Mapping not found");

        positions[currentPositionId] = Position(
            currentPositionId,
            msg.sender,
            block.timestamp,
            block.timestamp + (numDays * 1 days),
            tiers[numDays],  //% interest
            msg.value,
            calculateInterest(tiers[numDays], numDays, msg.value),
            true
        );

        positionIdsByAddress[msg.sender].push(currentPositionId);  //createed ew position
        currentPositionId += 1;
    }

    function calculateInterest(
        uint basisPoints,
        uint numDays,
        uint weiAmount
    ) private pure returns (uint) {
        return (basisPoints * weiAmount) / 10000;
    }

    //owner can modify  locking periods and interest rate
    function modifyLockPeriods(
        uint numDays,
        uint basisPoints
    ) external onlyOwner {

        tiers[numDays] = basisPoints; // updating interest rate
        lockPeriods.push(numDays);
    }

    //funtion to get the numberofdays for staking the funds on numberof days
    function getLockPeriods() external view returns (uint[] memory) {
        return lockPeriods;
    }

    function getInterestRate(uint numDays) external view returns (uint) {
        return tiers[numDays];
    }

    function getPositionById(
        uint positionId
    ) external view returns (Position memory) {
        return positions[positionId];
    }

    //query all the positions by address
    function getPositionIdsForAddress(
        address walletAddress
    ) external view returns (uint[] memory) {
        return positionIdsByAddress[walletAddress];
    }

    function changeUnlockDate(
        uint positionId,
        uint newUnlockDate
    ) external onlyOwner {
        positions[positionId].unlockDate = newUnlockDate;
    }

    //closing the postion after locking periods
    function closePosition(uint positionId) external {
        require(
            positions[positionId].walletAddress == msg.sender,
            "only position creator can modify the position"
        );
        require(
            positions[positionId].open == true,
            "this position is already closed"
        );

        positions[positionId].open = false; // position is closed

        //withdraw time should be greator than unlockDate if yes thenreturn amount with interest
        //if not then return only staked ethers
        if (block.timestamp > positions[positionId].unlockDate) {
            uint amount = positions[positionId].weiStacked +
                positions[positionId].weiInterest;
            payable(msg.sender).call{value: amount}("");
        } else {
            payable(msg.sender).call{value: positions[positionId].weiStacked}(
                ""
            );
        }
    }
}
