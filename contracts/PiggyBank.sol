// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PiggyBank is Ownable{
    uint256 public immutable withdrawalDate;
    address public immutable token;
    address public immutable manager;
    address public constant USDT = 0xdac17f958d2ee523a2206206994597c13d831ec7;
    address public constant USDC = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;
    address public constant DAI = 0x3e622317f8c93f7328350cf0b56d9ed4c620c5d6;
    string public savingPurpose;

    bool public finalized;

    // constructor
    constructor (uint256 _withdrawalDate, address _manager, address _token, string memory _savingPurpose) {
        require(_withdrawalDate > block.timestamp, 'WITHDRAWAL MUST BE IN FUTURE');

        withdrawalDate = _withdrawalDate;
        manager = _manager;
        token = _token;
        savingPurpose = _savingPurpose;
    }

    modifier allowedToken(address _token){
        require(_token == USDT || _token == USDC || _token == DAI, "Invalid token");
    }

    modifier notFinalized(){
        require(!finalized, "Contract's functionalities cannot be used");
    }

    // save
    function save (uint256 _amount) external notFinalzed allowedToken(msg.sender){

        require(msg.sender != address(0), 'Unauthorized address');

        require(block.timestamp <= withdrawalDate, 'You can no longer save');

        require(_amount > 0, 'Invalid amount');

        // transfer the token to the contract
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), 'Transfer Failed');
    }

    // withdrawal
    function withdrawal () external notFinalized{
       require(block.timestamp >= withdrawalDate, 'NOT YET TIME');

        uint256 _contractBal = IERC20(token).balanceOf(address(this));

        bool transaction = IERC20(token).transfer(msg.sender, _contractBal);

        require(transaction, "Transaction Failed");
    }

    //forced withdrawal
    function forcedWithdrawal() external notFinalized{
        uint256 _contractBal = IERC20(token).balanceOf(address(this));
        if(block.timestamp < withdrawalDate){
            uint256 penalty = (_contractBal * 15)/100;
            bool charge = IERC20(token).transferFrom(msg.sender, address(this), penalty);
            if(charge){
                bool transaction = IERC20(token).transfer(msg.sender, _contractBal);
                require(transaction, "Transaction Failed");
            }
        }
    }

    function finalized() external{
        require(msg.sender == manager, 'Not manager');
        finalized = true;
    }
}