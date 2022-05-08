// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeTransferLib} from "./libs/SafeTransferLib.sol";
import {PackedUint144} from "./libs/PackedUint144.sol";

import {Databank} from "./Databank.sol";
import {MainProtocol} from "./MainProtocol.sol";


/*
    Contract responsible for handling the protocol's daily reward pool allocation and distribution
*/

contract DailyPot is Ownable {
    using SafeTransferLib for ERC20;
    using PackedUint144 for uint144;

    uint dailyRewards;
    uint lastUpdateBlock;
    bool isDisabled;

    Databank DB;
    MainProtocol MP;
    

    struct DailyPool {
        address creator;            // 1st slot
        address token;              // 2nd slot
        uint160 dailyCap;        // 3rd slot
        uint32 endTime;             // 3rd slot
        uint256 rewardPerLiquidity; // 4th slot
        uint32 lastRewardTime;      // 5th slot
        uint112 rewardRemaining;    // 5th slot
        uint112 liquidityStaked;    // 5th slot
    }

    // Pool count won't be greater than type(uint24).max on mainnet.
    // This means we can use uint24 vlaues to identify pools.
    struct UserEarnings {
        uint112 earned;
        uint144 poolsActiveEarnings; // six packed uint24
    }

    // error codes: more to add

    error InvalidTimeframe();
    error DailyPoolOverflow();
    error PoolMaxClaimed();
    error PoolNilRewards();
    error NotActive();
    error OnlyCreator();
    error NoToken();

    // events: more to add
    event DailyPoolSpawned(address indexed token, uint indexed amount, uint id, uint startTime, uint endtime);
    event DailyPoolUpdated(uint indexed id, int changeAmount, uint _newStart, uint _newEnd);
    event RewardsReleased(uint indexed id, uint indexed paidOut, uint indexed poolDrained);
    event Subscribe(uint indexed id, address indexed user);
    event Unsubscribe(uint indexed id, address indexed user);
    event Stake(uint indexed id, address indexed user, uint amount, uint startTime);
    event Unstake(uint indexed id, address indexed user, uint amount, uint endTime);

    // id of pools(pool counter)
    uint public poolCount; 
    
    // Starts with 1. Zero is an invalid pool.
    mapping(uint => DailyPool) public pools;

    /// @dev userRewardPerLiq[user][poolId]
    /// @dev Semantic overload: if value is zero user isn't subscribed to the incentive.
    mapping(address => mapping(uint => uint)) public userRewardPerLiq;

    /// @dev usersEarnings[user][stakedToken]
    mapping(address => mapping(address => UserEarnings)) public usersEarnings;


constructor(Databank _db, MainProtocol _mp) {
    DB = _db;
    MP = _mp;
}

// called by relay/sentinel tasks to create a new reward pool each day to be earned from
/// @dev Creates pool and reduces the MainProtocol's holdings
// TODO: security checks via Main ensuring token holdings for new pool
function createPool(uint112 _rpd, uint160 _rpdc, address token, uint32 _startTime, uint32 _endTime) external returns(uint poolId) {
    if(poolId > type(uint24).max) revert DailyPoolOverflow();
    _saferTransferFrom(token, _rpd);
    pools[poolId] = DailyPool({
            creator: msg.sender,
            token: token,
            dailyCap: _rpdc,
            lastRewardTime: _startTime,
            endTime: _endTime,
            rewardRemaining: _rpd,
            liquidityStaked: 0,
            // Initial value of rewardPerLiquidity can be arbitrarily set to a non-zero value.
            rewardPerLiquidity: type(uint256).max / 2
    });
    emit DailyPoolSpawned(token, _rpd, poolId , block.timestamp, block.timestamp + 1 days);
}

function updatePool(uint _poolId, int112 _change, uint32 _newStart, uint32 _newEnd) external {
    DailyPool storage pool = pools[_poolId];
    if (msg.sender != pool.creator) revert OnlyCreator();

    // TODO: _updateRewards(pool)

    if(_newStart != 0 ) {
        if (_newStart < block.timestamp) _newStart = uint32(block.timestamp);
        pool.lastRewardTime = _newStart;
    }

    if(_newEnd != 0) {
        if(_newEnd < block.timestamp) _newEnd = uint32(block.timestamp);
        pool.endTime = _newEnd;
    }

    if(pool.lastRewardTime >= pool.endTime) revert InvalidTimeframe();

    if(_change > 0) {
        pool.rewardRemaining += uint112(_change);
        ERC20(pool.token).safeTransferFrom(msg.sender, address(this), uint112(_change));
    }else if (_change < 0) {
        uint112 transferOut = uint112(-_change);
        if(transferOut > pool.rewardRemaining) transferOut = pool.rewardRemaining;
        unchecked {
            pool.rewardRemaining -= transferOut;
        }

        ERC20(pool.token).safeTransfer(msg.sender, transferOut);
    }

    emit DailyPoolUpdated(_poolId, _change, _newStart, _newEnd);
}


function _saferTransferFrom(address token, uint256 amount) internal {

    if (token.code.length == 0) revert NoToken();

    ERC20(token).safeTransferFrom(msg.sender, address(this), amount);

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