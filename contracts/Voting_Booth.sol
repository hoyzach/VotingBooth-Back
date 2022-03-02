// SPDX-License-Identifier: Unlicensed

/*
Even though voter data is visible on the Ethereum blockchain, this application is written as if it isn't.
Additionally, solidity does not allow for functions to be called automatically after a specified period of time,
therefore this contract needs to use owner privileges to open and close a voting category.   
The ultimate decentralized voting application would not require owner privileges and would not allow anyone to 
see voting data as it is collected in order to discourage voting based on current current voting data and to 
protect the privacy of the individual voters.

This application does not prevent the same entity from creating multiple address to vote from.
A separate database with a voter identifcation number obtained through a voter identification verification
process would need to be queried through a modified register function. 
*/
pragma solidity ^0.8.0;

import "./Voting_Storage.sol";


contract VotingBooth is VotingStorage {

    function register() external {
        require(_registry[msg.sender] != true, "This address is already registered");
        _registry[msg.sender] = true;
        _voterCount++;
    }

    function setCategory(string memory _category, string[] memory _candidates) external onlyOwner returns (uint64){

        require(_candidates.length <256, "There are too many candidates.");

        //categories[_catCounter].push(_category, candidates.push(), false, _catCounter);
        categories.push();
        categories[_catCounter].name = _category;
        categories[_catCounter].catId = _catCounter;
        categories[_catCounter].candidates.push();

        for(uint8 i = 0; i < _candidates.length; i++) {
            //categories[_catCounter].candidates[i].push(_candidates[i], 0, i);
            categories[_catCounter].candidates[i].name = _candidates[i];
            categories[_catCounter].candidates[i].numCanVotes = 0;
            categories[_catCounter].candidates[i].canId = i;
        }

        _catCounter++;

        return _catCounter;        
    }

    function openCategory(uint64 _catId) external onlyOwner {
        require(categories[_catId].open == false);
        require(_openedOnce[_catId] == false);
        _openedOnce[_catId] = true;
        categories[_catId].open = true;
    }

    function closeCategory(uint64 _catId) external onlyOwner {
        require(categories[_catId].open == true);
        categories[_catId].open = false;
    }

    function castVote(uint64 _catId, uint8 _canId) external registered whenNotPaused returns(bool) {
        //prevent voter from voting in a closed category
        require(categories[_catId].open == true, "This category is not open for voting.");

        //prevent voter from voting for another candidate in the same category
        require(_boolVoter[msg.sender][_catId] == false, "You have already voted in this category");
        _boolVoter[msg.sender][_catId] = true;

        //add vote for cadidate
        categories[_catId].candidates[_canId].numCanVotes++;

        //add vote to totalVotes
        _totalVotes++;

        return true;
    }

    function getCategoryVotes(uint64 _catId) external view returns(uint) {
        require(categories[_catId].open == false);

        uint CategoryVotes = 0;
        for(uint8 i = 0; i < categories[_catId].candidates.length; i++) {
            CategoryVotes = CategoryVotes + categories[_catId].candidates[i].numCanVotes;
        }

        return CategoryVotes;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function withdraw() external onlyOwner {
        require(address(this).balance > 0, "No funds in contract");
        payable(msg.sender).transfer(address(this).balance);
    }
}