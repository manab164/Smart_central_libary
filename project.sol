// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EduContentLibrary {
    
    mapping(address => uint256) public balances;

    
    struct Content {
        address contributor;
        string contentHash;  
        string title;
        string description;
        uint256 timestamp;
        uint256 reward;
    }

    Content[] public contents;

    event ContentAdded(address indexed contributor, uint256 contentId, string title, uint256 reward);

    function addContent(string memory _contentHash, string memory _title, string memory _description, uint256 _reward) public {
        require(bytes(_contentHash).length > 0, "Content hash is required");
        require(bytes(_title).length > 0, "Title is required");
        require(_reward > 0, "Reward must be greater than zero");

        require(balances[msg.sender] >= _reward, "Insufficient balance to reward content");
        balances[msg.sender] -= _reward;

        contents.push(Content({
            contributor: msg.sender,
            contentHash: _contentHash,
            title: _title,
            description: _description,
            timestamp: block.timestamp,
            reward: _reward
        }));

        emit ContentAdded(msg.sender, contents.length - 1, _title, _reward);
    }

    function viewContent(uint256 _contentId) public view returns (address, string memory, string memory, string memory, uint256, uint256) {
        require(_contentId < contents.length, "Content ID out of bounds");

        Content memory content = contents[_contentId];
        return (content.contributor, content.contentHash, content.title, content.description, content.timestamp, content.reward);
    }

    function depositTokens(uint256 _amount) public payable {
        require(msg.value == _amount, "Ether value must match the token amount");

        balances[msg.sender] += _amount;
    }

    function withdrawTokens(uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance to withdraw");

        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }

    function getContentsCount() public view returns (uint256) {
        return contents.length;
    }
}
