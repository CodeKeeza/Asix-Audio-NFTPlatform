// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";


/*
    Central data reserve as the core truth for all core and peripheral contracts
*/

contract Databank is Ownable {

constructor() {}

struct User {
    uint earnings;
    uint artistEarnings;
    bool artist;
}

struct YearOne {
    uint RPA;
    uint RPD;
    uint RPDC;
}


mapping (address => User) userDetails;



}