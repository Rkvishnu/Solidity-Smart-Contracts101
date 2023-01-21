// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//smart contract for the government agencises
contract governance {
    address payable owner;

    struct Citizen {
        uint256 aadhar;
        string name;
        uint256 age;
        uint256 contact;
        string homeAddress;
        string gender;
        bool registered;
    }

    struct Official {
        uint256 officialId;
        string name;
        uint256 age;
        uint256 salary;
        uint256 contact;
        string designation;
        uint256 yearOfExp;
        string gender;
        bool registered;
    }

    Citizen[] citizensRecord;
    Official[] officialsRecord;

    constructor() {
        owner = payable(msg.sender);
    }

    //is the addres is govt. officials
    mapping(address => bool) public isOfficial;
    mapping(uint256 => bool) Registered;
    mapping(uint256 => uint256) citizensRecordIndex;
    mapping(uint256 => uint256) officialsRecordIndex;

    ///voting
    mapping(address => bool) public voters;
    mapping(address => uint256) public votes;

    // used for notifying if function is executed or not
    event Successfull(string message);

    function registerAsCititzens(
        string memory _name,
        uint256 _age,
        uint256 _contact,
        string memory _homeAddress,
        uint256 _aadhar,
        string memory _gender,
        bool _registered
    ) public {
        // require(!officials[msg.sender], "officials are already registred");
        require(Registered[_aadhar] != true, "citizen is already registered");

        uint256 index = citizensRecord.length;

        citizensRecord.push();
        citizensRecord[index].name = _name;
        citizensRecord[index].age = _age;
        citizensRecord[index].contact = _contact;
        citizensRecord[index].homeAddress = _homeAddress;
        citizensRecord[index].aadhar = _aadhar;
        citizensRecord[index].gender = _gender;
        citizensRecord[index].registered = _registered;

        // store the aaray index in the map against the user addhar number
        citizensRecordIndex[_aadhar] = index;
        Registered[_aadhar] = _registered;

        emit Successfull("citizen registred succesfully");
    }

    function registerAsOfficials(
        string memory _name,
        uint256 _age,
        string memory _designation,
        string memory _gender,
        uint256 _salary,
        uint256 _contact,
        uint256 _officialId,
        uint256 _yearOfExp,
        bool _registered
    ) public {
        require(
            Registered[_officialId] != true,
            "citizen is already registered"
        );

        uint256 index = officialsRecord.length;
        officialsRecord.push();

        officialsRecord[index].name = _name;
        officialsRecord[index].age = _age;
        officialsRecord[index].contact = _contact;
        officialsRecord[index].designation = _designation;
        officialsRecord[index].officialId = _officialId;
        officialsRecord[index].yearOfExp = _yearOfExp;
        officialsRecord[index].salary = _salary;
        officialsRecord[index].gender = _gender;
        officialsRecord[index].registered = _registered;

        //storing array index in the map against the offical's id
        officialsRecordIndex[_officialId] = index;
        Registered[_officialId] = _registered;

        emit Successfull("official is registered succesfully");
    }

    function voting(address candidate) public {
        require(!isOfficial[msg.sender], "officials can not vote");
        require(
            isOfficial[candidate],
            "candidate must be registered as official"
        );
        require(msg.sender != candidate, "you can not vote for yourself");

        voters[msg.sender] = true;
        votes[candidate]++;
    }

    function getVotes(address candidate) external view returns (uint256) {
        return votes[candidate];
    }

    function proposeLow(string memory proposal) public {
        require(isOfficial[msg.sender], "only officials can make proposal");
    }

    function enactLow(string memory proposal) public {
        require(msg.sender == owner, "only owner can enact the lows");
    }

    function getOfficialsRecord(uint256 _officialId)
        external
        view
        returns (Official[] memory)
    {
        require(msg.sender == owner, "Only owner can access this data");
        uint256 index = officialsRecordIndex[_officialId];
        return officialsRecord;
    }

    function getCitizensRecord(uint256 _aadhar)
        public
        view
        returns (Citizen[] memory)
    {
        require(msg.sender == owner, "Only owner can access this data");
        uint256 index = citizensRecordIndex[_aadhar];
        return citizensRecord;
    }

    function grantAccess(address payable user) public {
        require(msg.sender == owner, "only owner can grant the access");
        owner = user;
    }

    function revokeAccess(address payable user) public {
        require(msg.sender == owner, "only owner can revoke access");
        require(user != owner, "can not revoke access for the current owner");
        owner = payable(msg.sender);
    }

    function destroy() public {
        require(msg.sender == owner, "only owner can destroy this contract");
        selfdestruct(owner);
    }
}
