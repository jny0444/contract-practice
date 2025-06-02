// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract CrowdFund {
    uint256 public campaignCount = 0;

    struct Campaign {
        address creator;
        string title;
        string description;
        uint256 goal;
        uint256 deadline;
        uint256 amountRaised;
        bool completed;
    }

    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => mapping(address => uint256)) public contributions;
    mapping(uint256 => address[]) public contributors;

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _goal,
        uint256 _deadline
    ) public {
        require(_goal > 0, "Goal must be greater than 0");
        require(_deadline > block.timestamp, "Deadline must be in the future");

        campaigns[campaignCount] = Campaign({
            creator: msg.sender,
            title: _title,
            description: _description,
            goal: _goal,
            deadline: _deadline,
            amountRaised: 0,
            completed: false
        });

        campaignCount++;
    }

    function fundCampaign(uint256 _campaignId) public payable {
        require(_campaignId < campaignCount, "Campaign does not exist");
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than 0");
        require(!campaign.completed, "Campaign is already completed");

        if (contributions[_campaignId][msg.sender] == 0) {
            contributors[_campaignId].push(msg.sender);
        }

        contributions[_campaignId][msg.sender] += msg.value;
        campaign.amountRaised += msg.value;
    }

    function withdrawFromCampaign(uint256 _campaignId) public {
        require(_campaignId < campaignCount, "Campaign does not exist");
        Campaign storage campaign = campaigns[_campaignId];
        require(!campaign.completed, "Campaign is already completed");

        uint256 contribution = contributions[_campaignId][msg.sender];
        require(contribution > 0, "No contributions to withdraw");

        contributions[_campaignId][msg.sender] = 0;
        campaign.amountRaised -= contribution;

        (bool success, ) = msg.sender.call{value: contribution}("");
        require(success, "Withdrawal failed");
    }

    function endCampaign(uint256 _campaignId) public {
        require(_campaignId < campaignCount, "Campaign does not exist");
        Campaign storage campaign = campaigns[_campaignId];

        require(
            block.timestamp >= campaign.deadline || campaign.amountRaised >= campaign.goal,
            "Campaign is still active"
        );
        require(!campaign.completed, "Campaign is already completed");
        require(msg.sender == campaign.creator, "Only creator can end campaign");

        campaign.completed = true;

        if (campaign.amountRaised >= campaign.goal) {
            (bool success, ) = campaign.creator.call{value: campaign.amountRaised}("");
            require(success, "Transfer to creator failed");
        } else {
            address[] memory _contributors = contributors[_campaignId];
            for (uint256 i = 0; i < _contributors.length; i++) {
                address user = _contributors[i];
                uint256 refund = contributions[_campaignId][user];
                if (refund > 0) {
                    contributions[_campaignId][user] = 0;
                    (bool success, ) = user.call{value: refund}("");
                    require(success, "Refund failed");
                }
            }
            campaign.amountRaised = 0;
        }
    }
}
