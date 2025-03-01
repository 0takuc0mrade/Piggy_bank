// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract PiggyBank {
    uint256 public immutable withdrawalDate;
    address public immutable token;
    address public immutable manager;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant DAI = 0x3e622317f8C93f7328350cF0B56d9eD4C620C5d6;
    string public savingPurpose;

    bool public isFinalized;

    event deposited(address indexed user, uint256 amount);
    event withdrawn(address indexed user, uint256 amount);

    // constructor
    constructor (uint256 _withdrawalDate, address _manager, address _token, string memory _savingPurpose) {
        require(_withdrawalDate > block.timestamp, 'WITHDRAWAL MUST BE IN FUTURE');

        withdrawalDate = _withdrawalDate;
        manager = _manager;
        token = _token;
        savingPurpose = _savingPurpose;
    }

    modifier allowedToken(){
        require(token == USDT || token == USDC || token == DAI, "Invalid token");
        _;
    }

    modifier notFinalized(){
        require(!isFinalized, "Contract's functionalities cannot be used");
        _;
    }

    // save
    function save (uint256 _amount) external notFinalized allowedToken{

        require(msg.sender != address(0), 'Unauthorized address');

        require(block.timestamp <= withdrawalDate, 'You can no longer save');

        require(_amount > 0, 'Invalid amount');

        // transfer the token to the contract
        require(IERC20(token).transferFrom(msg.sender, address(this), _amount), 'Transfer Failed');
        emit deposited(msg.sender, _amount);
    }

    // withdrawal
    function withdrawal () external notFinalized{
       require(block.timestamp >= withdrawalDate, 'NOT YET TIME');

        uint256 _contractBal = IERC20(token).balanceOf(address(this));

        bool transaction = IERC20(token).transfer(msg.sender, _contractBal);

        require(transaction, "Transaction Failed");
        emit withdrawn(msg.sender, _contractBal);
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
                emit withdrawn(msg.sender, _contractBal);
            }
        }
    }

    function finalized() external{
        require(msg.sender == manager, 'Not manager');
        isFinalized = true;
    }
}