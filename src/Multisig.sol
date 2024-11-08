pragma solidity ^0.8.7;

import "./State.sol";

contract Multisig is State {

    constructor(address[] memory newValidators,  uint256 _quorum){
        
    }

    function addValidator(address validator, uint256 newQuorum) external {

    }

    function removeValidator(address validator, uint256 newQuorum) external {

    }

    function replaceValidator(address validator, address newValidator) external {
    }

    function changeQuorum(uint256 _quorum) external {
    }

    function transactionExists(bytes32 transactionId) external view returns (bool){
        return false;
    }

    function createTransaction(bytes32 transactionId,
        address destination,
        uint256 value,
        bytes calldata data,
        bool hasReward) public payable {
        
        }

    function voteForTransaction(bytes32 transactionId) external {

    }

    function executeTransaction(bytes32 transactionId) public {
        
    }

    function removeTransaction(bytes32 transactionId) external {
        
    }

    function isConfirmed(bytes32 transactionId) external view returns (bool) {
        return false;
    }

    function getDataOfTransaction(bytes32 id) external view returns (bytes memory data){
        
    }

    function hash(bytes memory data) external pure returns (bytes32 result){
        result = keccak256(data);
    }

    function getConfirmationCount(bytes32 transactionId) external view returns (uint256 count){
        
    }

    function distributeRewards() external {
        
    }
}