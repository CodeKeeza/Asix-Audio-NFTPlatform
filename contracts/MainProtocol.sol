// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Databank.sol";
import "./DailyPot.sol";


/*
    Central contract that controls the peripheral contracts associated with the protocol
    Manages variables and state for peripheral contracts
    Overseer contract that rules all children contracts
*/

contract MainProtocol is Ownable {

    Databank DB;
    DailyPot DP;
    

constructor(Databank _db, DailyPot _dp) {
    DB = _db;
    DP = _dp;
}

// Used only by the owner to rescue tokens sent to the contract address
// additional checks needed to ensure core tokens can't be removed affecting the protocol
function contractTokenRescue(address _token) external onlyOwner {
    uint bal = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transferFrom(address(this), msg.sender, bal);
}

// Used to rescue any ether sent to the contract address
function contractEthRescue() external onlyOwner {
    payable(msg.sender).transfer(address(this).balance);
}

receive() external payable{}
fallback() external payable {} 


}