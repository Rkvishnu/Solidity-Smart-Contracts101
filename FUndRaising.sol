 //SPDX-License-Identifier:MIT
pragma solidity >=0.4.0 < 0.9.0;

contract fundRaising {
    //mapping for the donors who contributed in the camapign
    mapping(address => uint) public donors;

    //contribution done by  the contributor
    mapping(address => uint) public contribution;

    address public admin;
    uint public noOfContributors;
    uint public minimumContribution;
    uint public deadline; //this is a timestamp (seconds)
    //amount that must be raised for a successful Campaign
    uint public goal;
    uint public raisedAmount = 0;

    //Spending Request created by admin to spend money, must be voted by  51% contributors
    struct Request{
        string description;
        address recipient;
        uint value;
        bool completed;
        uint noOfVoters;
        mapping(address => bool) voters;
    }
//dynamic array of requests
Request[] public requests;

    event ContributeEvent(address sender, uint value);
    event CreateRequestEvent(
        string _description,
        address _recipient,
        uint value
    );
    event MakePaymentEvent(address recipient, uint value);

    constructor(uint _goal, uint _deadline) public {
        goal = _goal;
        deadline = now + _deadline;
        admin = msg.sender;
        minimumContribution = 1;
    }

    // only Admin can call this function
    modifier onlyAdmin() {
        require(msg.sender == admin);
        _;
    }

    //function to contribute in the campaign
    function Contribute(uint amount) public payable {
        require(block.timestamp < deadline, "dealine is over");
        require(msg.value >= minimumContribution, "Must pay minimum amount");
        noOfContributors++;
        contribution[msg.sender] += amount;
        raisedAmount += amount;
        emit ContributeEvent(msg.sender, amount);
    }

    // fucntion to get the raisedAmount in this contract
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // functon to get your refund if goal not completed in deadline]
    function getRefund() public {
        require(block.timestamp > deadline, "campaign not over yet");
        require(contribution[msg.sender] > 0, "your contribution is 0");
        require(raisedAmount < goal, "you can not withdra money");

        address recipient = msg.sender;
        uint value = contribution[msg.sender]; // contribution done by person
        recipient.transfer(value); // trnafer money in person's address
        contribution[msg.sender] = 0;
    }

   //admin creates spending request to spend the money for their neeed
   function createRequest(string _description, address _recipient, uint _value) public onlyAdmin {
    Request memory newRequest = Request({
       description: _description,
       recipient: _recipient,
       value: _value,
       completed: false,
       noOfVoters: 0   
    });

    requests.push(newRequest);
    emit CreateRequestEvent(_description,_recipient,_value);
}


// contributors can vote for the request wheather this request should be accepted or not
 function  voteOnRequest(uint index) public{
    Request storage thisRequest= requests[index];   // admin make request for the need

    require(contribution[msg.sender]>0, "you can not vote"); 
    require(thisRequest.voters[msg.sender]==false,"admin can not vote");  

    thisRequest.voters[msg.sender]==true;
    thisRequest.noOfVoters++;
 }


 //  if vote is greater then 50% then owner  now can send money to the recipient(may be seller,vendor)
 function makePayment(uint index) public onlyAdmin{
    Request storage thisRequest = requests[index];
    
    require(thisRequest.completed==false);
    require(thisRequest.noOfVoters > noOfContributors/2); // more then 50% people must be voted

    thisRequest.recipient.transfer(thisRequest.value); //now transfer money to the rcipient

    thisRequest.completed==true; 
     emit MakePaymentEvent(address recipient,uint value);
 }
 
   //if voted, owner sends money to the recipient (vendor, seller)
    function makePayment(uint index) public onlyAdmin{
        Request storage thisRequest  = requests[index];
        require(thisRequest.completed == false);
        
        require(thisRequest.noOfVoters > noOfContributors / 2);//more than 50% voted
        thisRequest.recipient.transfer(thisRequest.value); //trasfer the money to the recipient
        
        thisRequest.completed = true;
        emit MakePaymentEvent(address recipient, uint value);
    }

}
