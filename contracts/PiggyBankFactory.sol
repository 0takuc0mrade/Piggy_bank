// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyBankFactory{
    mapping(address => address[]) public userBanks;
    event bankCreated(address indexed owner, address piggybank, string savingPurpose);

    function createBank(uint256 _withdrawalDate, address _token, string memory _savingPurpose) external{
        bytes32 _salt = keccak256(abi.encode(block.timestamp, msg.sender, _token, _savingPurpose));
        PiggyBank bank = new PiggyBank{salt: _salt}(_withdrawalDate, msg.sender, _token, _savingPurpose);
        address bankAddress = address(bank);

        userBanks[msg.sender].push(bankAddress);
        emit bankCreated(msg.sender, bankAddress, _savingPurpose);
    }

    function getUserBanks(address user) external view returns(address[] memory){
        return userBanks[user];
    }
}