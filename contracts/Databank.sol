// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


/*
    Central data reserve as the core truth for all core and peripheral contracts
*/

contract Databank is Ownable {

    uint public rewardsPerDay;
    uint public rewardsPerShare;
    uint public rewardsMultiplier;

    uint public totalRewards;

constructor() {}

struct User {
    uint earnings; // earnings through dapp interaction and use
    uint artistEarnings; // earnings through NFT creation and service provision
    bool artist; // is artist on not?
}

struct YearlyStats {
    uint RPA; // Rewards Per Annum 
    uint RPD; // Rewards Per Day
    uint RPDC; // Rewards Per Day Cap
}

YearlyStats[] public yearlyEmissions;
User[] public userDetails;

mapping (address => User) public userMapping;

// Sets the yearly stats for the protocol regarding emissions
function setYearly(uint _rpa, uint _rpd, uint _rpdc) public onlyOwner {
    yearlyEmissions.push(YearlyStats(_rpa, _rpd, _rpdc));
}

}