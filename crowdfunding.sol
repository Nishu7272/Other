// SPDX-License-Identifier: GPL-3.0

pragma solidity= 0.8.7;

contract CrowdFunding
{
    //writing out all the variables and mapping we will need for this contract
 mapping(address=>uint) public contributors;
 uint public noOfContributors;
 uint public minimumcontribution;
 uint public raisedamount;
 uint public target;
 uint public deadline;
 address public manager;

 //For Manager
 struct Request{
     string discription;
     address payable recepient;
     uint value;
     bool completed;
     uint noOfvoters;
     mapping(address=>bool) voters;
 }

 // Indexing Request 
 mapping(uint=>Request) public request;
 uint public numRequest;

// Defining things needed for our contract
 constructor(uint _target, uint _deadline)
 {
     target=_target;
     deadline=block.timestamp+_deadline;
     minimumcontribution=100 wei;
     manager=msg.sender;  
 }

// calling out our first function
 function sendEth() public payable
 {
     // Requirements for the function to run
     require(msg.value>=minimumcontribution,"You are not eligible");
     require(block.timestamp<deadline,"Deadline has passed");

     // considerations and change difination 
     if(contributors[msg.sender]==0)
     {
         noOfContributors++;
     }
     contributors[msg.sender]+=msg.value;
     raisedamount+=msg.value;
 }

// Result of the function
 function getContractBalance() public view returns(uint)
 {
     return address(this).balance;
 }
 
 //For refund
 function refund() public
 {
     //Refund Requirement
      require(raisedamount<target && block.timestamp>deadline,"You are not eligible for refund");
      require(contributors[msg.sender]>0);
      
      //Refund process
      address payable user=payable(msg.sender);
      user.transfer(contributors[msg.sender]);
      contributors[msg.sender]=0;   
 }
// Giving access to only manager
 modifier onlyManger{
     require(msg.sender==manager,"Only Manger can access this function");
     _;
 }
// Function to create new request
 function createRequests(string memory _discription,address payable _recepient,uint _value) public onlyManger
 {
     Request storage newRequest=request[numRequest];
     numRequest++;
     newRequest.discription=_discription;
     newRequest.recepient=_recepient;
     newRequest.value=_value;
     newRequest.completed=false;
     newRequest.noOfvoters=0;
 }
// Function to add vote request
 function voteRequest(uint _requestNo) public 
 {
     require(contributors[msg.sender]>0,"You need to be contributors first");
     Request storage thisRequest=request[_requestNo];//pointing a structure
     require(thisRequest.voters[msg.sender]==false,"You have already voted");
     thisRequest.voters[msg.sender]=true;
     thisRequest.noOfvoters++;
 }
// Function to make payment by only manager
 function makePayment(uint _requestNo) public onlyManger
 {
     require(raisedamount>=target);
     Request storage thisRequest=request[_requestNo];
     require(thisRequest.noOfvoters>noOfContributors/2,"Majority does not support");
     require(thisRequest.completed==false,"Payment has been done");
     thisRequest.recepient.transfer(thisRequest.value);
 }

}
