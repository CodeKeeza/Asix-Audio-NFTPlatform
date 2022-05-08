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

    uint public userCount; 
    uint public artistCount;

    address immutable NULL_ADDR = 0x0000000000000000000000000000000000000000;

constructor() {}

struct SubTiersFees {
    uint bronzeFee;
    uint silverFee;
    uint goldFee;
}

SubTiersFees public tierFees;

// sets the fees for the protocol subscription tiers
// subscription paid with AsixMusicToken so values must reflect those tokenomics
function setFees(uint _bronze, uint _silver, uint _gold) public onlyOwner {
    require(_bronze > 0 && _silver > 0 && _gold > 0, "All values must be entered and more than 0");
    tierFees.bronzeFee = _bronze;
    tierFees.silverFee = _silver;
    tierFees.goldFee = _gold;
}

struct YearlyStats {
    uint RPA; // Rewards Per Annum 
    uint RPD; // Rewards Per Day
    uint RPDC; // Rewards Per Day Cap
}

YearlyStats[] public yearlyEmissions;

// Sets the yearly stats for the protocol regarding emissions
function setYearly(uint _rpa, uint _rpd, uint _rpdc) public onlyOwner {
    yearlyEmissions.push(YearlyStats(_rpa, _rpd, _rpdc));
}

struct User {
    string name;
    address wallet;
    uint earnings; // earnings through dapp interaction and use
    uint artistEarnings; // earnings through NFT creation and service provision
    uint id; // user id
    bool artist; // is artist on not?
    SubTiersStatus tier;
}

User[] public userDetails;
mapping (address => User) public userMapping;


function addUser(address _who, string calldata _name, bool _artist, SubTiersStatus _tier) public onlyOwner returns(User memory){
    require(_artist, "Must select true or false");
    require(userMapping[_who].wallet == 0x0000000000000000000000000000000000000000, "Wallet already registered");
    if(_artist == false) { artistCount--;} else { artistCount++; }     userCount++;
    User memory user = User({
        name: _name,
        wallet: _who,
        earnings: 0,
        artistEarnings: 0,
        id: userCount,
        artist: _artist,
        tier: _tier // 0 = Free, 1 = Bronze, 2 = Silver, 3 = Gold
    });
    userDetails.push(user);
    userMapping[_who] = user;
    return user;
}

function getUser(uint _index) public view returns(User memory) {
    require(userDetails[_index].wallet != NULL_ADDR, "Wallet is not registered");
    User storage user = userDetails[_index];
    return user;
}
function getUserByAddress(address _who) public view returns(User memory) {
    require(userMapping[_who].wallet != NULL_ADDR, "Wallet is not registered");
    User storage user = userMapping[_who];
    return user;
}
// toggles user artist status
function updateUserArtistStatus(address _who, bool _artist) public returns(User memory) {
    require(userMapping[_who].wallet != NULL_ADDR, "Wallet is not registered");
    User storage user = userMapping[_who];
    user.artist = _artist;
    if(_artist == false) { artistCount--;} else { artistCount++; }
    return user;
}
enum SubTiersStatus {Free, Bronze, Silver, Gold}

SubTiersStatus public subTier;

// grabs the user tier if there is a user
function getTier(address _who) public view returns (SubTiersStatus){
    require(userMapping[_who].wallet != NULL_ADDR, "Wallet is not registered");
    return userMapping[_who].tier;
}
// sets the user tier
// address + {0,1,2,3}
function setTier(address _who, SubTiersStatus _tier) public {
    require(userMapping[_who].wallet != NULL_ADDR, "Wallet is not registered");
    userMapping[_who].tier = _tier;
}
// resets tier to free status
function resetToFree(address _who) public {
    require(userMapping[_who].wallet != NULL_ADDR, "Wallet is not registered");
    delete userMapping[_who].tier;
}

}