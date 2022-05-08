// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeTransferLib} from "./libs/SafeTransferLib.sol";

import {Databank} from "./Databank.sol";
import {DailyPot} from "./DailyPot.sol";



/*
    Central contract that controls the peripheral contracts associated with the protocol
    Manages variables and state for peripheral contracts
    Overseer contract that rules all children contracts
*/



contract MainProtocol is DailyPot {
    using SafeTransferLib for ERC20;

    Databank DB;
    DailyPot DP;

constructor(Databank _db) {
    DB = _db;
}

function setPot(DailyPot _where) public onlyOwner {
    DP = _where;
}
function createPool(uint112 _rpd, uint160 _rpdc, address _token, uint32 _startTime, uint32 _endTime) public {
    super._createPool(_rpd, _rpdc, _token, _startTime, _endTime);
}

function updatePool(uint _poolId, int112 _change, uint32 _newStart, uint32 _newEnd) public {
    super._updatePool(_poolId, _change, _newStart, _newEnd);
}

function _saferTransferFrom(address token, uint256 amount) internal override {

    if (token.code.length == 0) revert NoToken();

    ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

}

// Used only by the owner to rescue tokens sent to the contract address
// additional checks needed to ensure core tokens can't be removed affecting the protocol
function _contractTokenRescue(address _token) internal override  {
    uint bal = IERC20(_token).balanceOf(address(this));
    IERC20(_token).transferFrom(address(this), msg.sender, bal);
}

// Used to rescue any ether sent to the contract address
function _contractEthRescue() internal override  {
    payable(msg.sender).transfer(address(this).balance);
}

receive() external payable override{}
fallback() external payable override {} 

}