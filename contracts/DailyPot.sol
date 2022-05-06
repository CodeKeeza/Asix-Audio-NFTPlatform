// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Databank.sol";
import "./MainProtocol.sol";


/*
    Contract responsible for handling the protocol's daily reward pool allocation and distribution
*/

contract DailyPot is Ownable {

    uint dailyRewards;
    uint lastUpdateBlock;
    bool isDisabled;

    Databank DB;
    MainProtocol MP;

constructor(Databank _db, MainProtocol _mp) {
    DB = _db;
    MP = _mp;
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