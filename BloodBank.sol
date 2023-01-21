
// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract BloodBank {
    // set the owner of the contract
    address owner; 

    constructor() {
        owner = msg.sender;
    }

    // Used for defining PatientType
    enum PatientType {
        Donor,
        Receiver
    }

    // Used to storing blood txn
    struct BloodTransaction {
        PatientType patientType;
        uint256 time;
        address from;
        address to;
    }

    // Used for storing single Patient records
    struct Patient {
        uint256 aadhar;
        string name;
        uint256 age;
        string bloodGroup;
        uint256 contact;
        string homeAddress;
        BloodTransaction[] bT;
        bool registered;
    }

    // Array to store all the patientRecord
    // Array is used so that all the patientRecord can be fetched at once
    Patient[] PatientRecord;
    PatientType Ptype;

    // map is used to map the addhar card with the index number of the array where patient record is stored
    // this will prevent the use of loop in contract
    mapping(uint256 => uint256) PatientRecordIndex;
    mapping(uint256 => bool) Registered;
    

    // used for notifying if function is executed or not
    event Successfull(string message);

    // Register a new patient
    function newPatient(string memory _name,uint256 _age,string memory _bloodGroup,uint256 _contact,string memory _homeAddress,uint256 _aadhar,bool _registered) external {
        
        // get the legth of array
        uint256 index = PatientRecord.length;

        // Since patient can be only registered by the hospital hence its required to check if the sender is owner or not
        require(msg.sender == owner, "only admin can register new patient");
        require(Registered[_aadhar] != true, "Patient is already registered");
        

        // insert records
        PatientRecord.push();
        PatientRecord[index].name = _name;
        PatientRecord[index].age = _age;
        PatientRecord[index].bloodGroup = _bloodGroup;
        PatientRecord[index].contact = _contact;
        PatientRecord[index].homeAddress = _homeAddress;
        PatientRecord[index].aadhar = _aadhar;
        PatientRecord[index].registered = _registered;

        // store the aaray index in the map against the user addhar number
        PatientRecordIndex[_aadhar] = index;
        Registered[_aadhar] = _registered;

        emit Successfull("Patient added successfully");
    }

    // function to get specific user data
    function getPatientRecord(uint256 _aadhar) external view returns (Patient memory)
    {
        require(msg.sender == owner , "Only owner can access this data");
        uint256 index = PatientRecordIndex[_aadhar];
        return PatientRecord[index];
    }

    // store the blood txn
    function bloodTransaction(uint256 _aadhar,PatientType _type,address _from,address _to) external {
        // check if sender is hospital or not
        require(msg.sender == owner,"only hospital can update the patient's blood transaction data");
        
        
        // get at which index the patient registartion details are saved
        uint256 index = PatientRecordIndex[_aadhar];

        //insert the BloodTransaction in the record
        
            BloodTransaction memory txObj = BloodTransaction({
            patientType: _type,
            time: block.timestamp,
            from: _from,
            to: _to
            });


        PatientRecord[index].bT.push(txObj);

        // Note: above statement can also be written like below statement;
        // PatientRecord[index].bT.push(BloodTransaction(_type, block.timestamp,_from,_to));

        emit Successfull(
            "Patient blood transaction data is updated successfully"
        );
    }
    // function to get all the records
    function getAllRecord() external view returns (Patient[] memory) {
        require(msg.sender == owner , "Only Owner can access the data");
        return PatientRecord;
    }
}