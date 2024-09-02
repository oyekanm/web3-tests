// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

contract Crowdfunding {
    uint256 public promptCount = 0;
    struct Fundingprompt{
        string title;
        string description;
        uint256 goal;
        address owner;
        uint256 deadline;
        uint256 amountCollected;
        string image;
        address[] donators;
        mapping(address => uint256) donations;
    }
    mapping(uint256=>Fundingprompt) public fps;
    
    event FundingPromptCreated(uint256 indexed promptId, address indexed owner, string title, uint256 goal);
    event Donated(uint256 indexed promptId, address indexed donor, uint256 amount);

// Add this line at the end of the createFundingPrompt function:

    function createCampaign(
        string memory _title,
        string memory _description,
        uint256 _goal,
        uint256 _deadline,
        string memory _image
    ) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(_goal > 0, "Goal must be greater than 0");
        // require(_deadline > block.timestamp, "Deadline must be in the future");
        promptCount++;
        Fundingprompt storage fd = fps[promptCount];

        fd.title = _title;
        fd.deadline = _deadline;
        fd.amountCollected=0;
        fd.description=_description;
        fd.goal=_goal;
        fd.owner=msg.sender;
        fd.image=_image;

        emit FundingPromptCreated(promptCount, msg.sender, _title, _goal);
    }

    function donate(uint256 _id) public payable {
        require(_id <= promptCount, "Invalid funding prompt ID");
        require(msg.value > 0.00 ether, "please add a value to donate");
        Fundingprompt storage fp = fps[_id];

        payable(fp.owner).transfer(msg.value);
        // (bool sent,) = payable(fp.owner).call{value: msg.value}("");
          require(block.timestamp <= fp.deadline, "Funding deadline has passed");

        fp.amountCollected += msg.value;
        fp.donations[msg.sender] += msg.value;
        fp.donators.push(msg.sender);

        emit Donated(_id, msg.sender, msg.value);

        // return fp.donators;
    }

    function getDonators(uint256 _id) view public returns (address[] memory) {
        return fps[_id].donators;
    }

    function getFundingprompt(uint256 id) public view returns (
        string memory _title,
        string memory _description,
        uint256 _goal,
        address _owner,
        uint256 _deadline,
        uint256 _amountCollected,
        string memory _image,
        address[] memory _donators
    ) {
        // Fundingprompt[] storage Fundingprompts = new Fundingprompt[](promptCount);
        Fundingprompt storage Fundingprompts = fps[id];

        // for(uint i = 0; i < promptCount; i++) {
        //     Fundingprompt storage item = fps[i];
        //     Fundingprompts[i] = item;
        // }

        return (
            Fundingprompts.title,
            Fundingprompts.description,
            Fundingprompts.goal,
            Fundingprompts.owner,
            Fundingprompts.deadline,
            Fundingprompts.amountCollected,
            Fundingprompts.image,
            Fundingprompts.donators
        );
    }
}