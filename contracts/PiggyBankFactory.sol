// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "./PiggyBank.sol";

contract PiggyBankFactory{
    mapping(address => address[]) public userBanks;

    function createBank(uint256 _withdrawalDate, address _token, string memory _savingPurpose) external{
        bytes32 salt = keccak256(abi.encode(block.timestamp, msg.sender, _token, _savingPurpose));
        PiggyBank bank = new PiggyBank(salt: salt)(_withdrawalDate, msg.sender, _token, _savingPurpose);
        address bankAddress = address(bank);

        userBanks[msg.sender].push(bankAddress);
    }

    function getUserBanks(address user) external view returns(address[]){
        return userBanks[user];
    }
}