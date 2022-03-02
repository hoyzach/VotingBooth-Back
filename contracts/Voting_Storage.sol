// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract VotingStorage is Ownable, Pausable{

    modifier registered() {
        require(_registry[msg.sender] == true);
        _;
    }

    struct Candidate {
        string name;
        //bytes32 bytesName; //not used, added for compatibility
        uint numCanVotes;
        uint8 canId;
    }

    struct Category {
        string name;
        //bytes32 bytesName; //not used, added for compatibility
        Candidate[] candidates;
        bool open;
        uint64 catId;
    }

    Category[] public categories;
    uint64 _catCounter = 0;

    // address => bool --- list of voter addresses registered to site
    mapping (address => bool) public _registry;
    // address => categoryId => bool --- 1 vote per voter per category
    mapping (address => mapping(uint => bool)) public _boolVoter;
    // categoryId => bool --- categories can only be opened one time
    mapping (uint64 => bool) public _openedOnce;

    // total voters registered
    uint64 public _voterCount;
    // total votes recorded on application
    uint public _totalVotes;
    
}