// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Election {
    //candidate's details
    struct Candidate {
        uint CId;
        string cname;
        uint voteCount;
        string electionName;
        string electionId;
    }

    mapping(uint => Candidate) public candidates;
    mapping(address => bool) public voters;

    uint public candidatesCount;

    event votedCount(uint indexed _candidateId);

    function addCandidate(
        string memory _name,
        string memory _details,
        string memory _electionId
    ) public {
        candidatesCount++;
        candidates[candidatesCount] = Candidate(
            candidatesCount,
            _name,
            0,
            _details,
            _electionId
        );
    }

    function vote(uint _candidateId) public {
        require(!voters[msg.sender]);

        require(_candidateId > 0 && _candidateId <= candidatesCount);

        voters[msg.sender] = true;

        candidates[_candidateId].voteCount++;

        emit votedEvent(_candidateId);
    }
}
