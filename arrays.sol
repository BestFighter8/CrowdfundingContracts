// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

//here refund() doesn't work, no idea how to delete past transactions on refunding, so I'd rather leave it turned off, 
//so the person coulodn't take all the money from contract

contract CrowdfundingCampaign {

    address payable public deployer;

    constructor() {
        deployer = payable(msg.sender); //to recieve commision, can be edited to specific wallet
    }
    struct Campaign {
        uint campaignID;
        address payable owner;
        string title;
        string description;
        string image;
        uint duration;
        uint raisingGoal;
        uint deadline;
        uint amountCollected;
        address[] donators;
        uint256[] donations;
    }

    mapping(uint => Campaign) public campaigns;

    uint public numberOfCampaigns = 0;

    function createCampaign(
        uint _duration,
        uint _raisingGoal,
        string memory _title,
        string memory _description,
        string memory _image
    )public returns (uint256) {

        uint _campaignID = numberOfCampaigns++;
        uint _deadline = block.timestamp + _duration;

        campaigns[_campaignID].campaignID = _campaignID;
        campaigns[_campaignID].owner = payable(msg.sender);
        campaigns[_campaignID].title = _title;
        campaigns[_campaignID].description = _description;
        campaigns[_campaignID].image = _image;
        campaigns[_campaignID].duration = _duration;
        campaigns[_campaignID].raisingGoal = _raisingGoal;
        campaigns[_campaignID].deadline = _deadline;
        campaigns[_campaignID].amountCollected = 0;
        return numberOfCampaigns - 1;
    }

    // function to add ETH to a specific campaign, checked if it's still ongoing, stores donator and amount of ETH
    function donateToCampaign(
        uint _campaignID
        ) public payable {
        Campaign storage campaign = campaigns[_campaignID];
        require(campaign.campaignID != 0, "Campaign does not exist.");
        require(block.timestamp < campaign.deadline, "Campaign deadline has passed.");
        campaign.amountCollected += msg.value;  // <-- transfer msg.value here and add it to amountCollected
        campaign.donators.push(msg.sender);
        campaign.donations.push(msg.value);
    }

    // Old refund function, I don't know how to edit or compare data in arrays as in mappings
    // function refund(uint _campaignID) public {
    //     Campaign storage campaign = campaigns[_campaignID];
    //     require(campaign.campaignID != 0, "Campaign does not exist.");
    //     require(campaign.amountCollected < campaign.raisingGoal, "Campaign goal has been reached.");
    //     // require(block.timestamp > campaign.deadline, "Campaign deadline has not passed."); // <-- refund only if campaign fails
    //     require(campaign.donators[msg.sender] > 0, "You have not contributed to this campaign.");
    //     address payable sender = payable(msg.sender);
    //     // Refund the caller's contribution
    //     uint amount = campaign.donators[msg.sender]; // <-- get the transfer value from mapping storage
    //     (bool sent, ) = sender.call{value: amount}(""); // <-- check if the transfer was successful, return 'sent' on success
    //     require(sent, "ETH Refund failed"); // <-- if no 'sent', return an error
    //     campaign.donators[msg.sender] = 0;  // <-- set contribution to 0
    //     campaign.amountCollected -= amount; // <-- decrease campaigns 'amountCollected', delete campaign when all funds returned
    // }

    function withdrawFunds(uint _campaignID) public { // <-- only available for Campaign creator, if funds were fully raised
        Campaign storage campaign = campaigns[_campaignID];
        require(campaign.campaignID != 0, "Campaign does not exist.");
        require(campaign.amountCollected >= campaign.raisingGoal, "Campaign goal has not been reached."); // <-- check fund goal
        require(msg.sender == campaign.owner, "Only the campaign creator can withdraw funds."); // <-- check caller's adress, fail if not owner
        uint commission = campaign.amountCollected * 5 / 100;
        uint withdrawalAmount = campaign.amountCollected - commission;
        (bool sent, ) = campaign.owner.call{value: withdrawalAmount}(""); // <-- withdraw funds only for called Campaign, returns 'sent' on success
        require(sent, "ETH Withdrawal failed"); // <-- if no 'sent', return an error
        (bool commissioned, ) = deployer.call{value: commission}(""); // <-- send those 5% comission to contract deployer only on campaign success (so upon funds withdrawal) 
        require(commissioned, "Commission transfer failed");

    }
	
    //used to display info from arrays to show donators on website
    function getDonators(uint256 _campaignID) view public returns (
        address[] memory, uint256[] memory) {
        return (campaigns[_campaignID].donators, campaigns[_campaignID].donations);
    }

    //loop to iterate though the storage and get all data about campaigns
    function getCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](numberOfCampaigns);

        for (uint i = 0; i < numberOfCampaigns; i++) {
            Campaign storage item = campaigns[i];
            allCampaigns[i] = item;
        }

        return allCampaigns;
    }

    function getCurrentTime()public view returns(uint){ // <-- function to get a current time, used that only for testing
        return block.timestamp;
    }
}
