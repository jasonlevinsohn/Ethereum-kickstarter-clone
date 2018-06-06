pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;
    
    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);  // msg.sender is who is creating the contract
        deployedCampaigns.push(newCampaign);
    }
    
    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}


contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }
    // **************************
    // ***** Mapping Types ******
    // **************************
    // Keys are not stored in Solidity.  you can't get a list of
    // keys for a mapping.  you can not loop through a mapping and 
    // are not iterable.  No For Loops available.
    // All values exist in mappings.  if the lookup does not exist
    // you will get back empty string, not undefined.
    
    
    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    // address[] public approvers // will take too long to iterate over
    mapping(address => bool) public approvers;
    uint public approversCount;
    
    // Traditionally we place all modifiers above the contstructor.
    modifier restricted() {
        require(msg.sender == manager);
        _;
    }
    
    constructor(uint minimum, address creator) public {
        manager = creator;  // creator is who is creating the contract
        minimumContribution = minimum;
    }
    
    function contribute() public payable {
        require(msg.value > minimumContribution);
        
        //approvers.push(msg.sender); // we are using a mapping instead
        approvers[msg.sender] = true;
        approversCount++;
    }
    
    function createRequest(string description, uint value, address recipient) public restricted {
        // keyword `storage` stores a reference or pointer
        // keyword `memory` creates a copy
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        
        requests.push(newRequest);
    }
    
    function approveRequest(uint index) public {
        Request storage request = requests[index];
        // Make sure sender is an approver
        require(approvers[msg.sender]);
        
        // Make sure the sender has not already voted on the requests
        require(!request.approvals[msg.sender]);
        
        // If the known approver has not voted, count their vote.
        request.approvals[msg.sender] = true;
        request.approvalCount++;
        
    }
    
    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        
        require(request.approvalCount >= (approversCount / 2));
        require(!request.complete);
        
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary() public view returns (
        uint, uint, uint, uint, address
    ) {
        return (
            minimumContribution,
            this.balance,
            requests.length,
            approversCount,
            manager
        );
    }

    function getRequestsCount() public view returns (uint) {
        return requests.length;
    }
}
