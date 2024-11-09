pragma solidity ^0.8.7;

import "./State.sol";

contract Multisig is State {
    error ZeroAddress();
    error InvalidDestination();
    error InvalidQuorum();
    error InvalidCreator();
    error InvalidValidator();
    error InvalidTick();
    error InvalidTransactionId();
    error TransactionNotFound();
    error InsufficientValue();
    error InvalidConfirmation();
    error TransactionAlreadyExists();
    error TransactionAlreadyConfirmed();
    error TransactionAlreadyExecuted();
    error TransactionAlreadyRemoved();
    error TransactionNotConfirmed();
    error InsufficientBalance();
    error DuplicateValidator();
    error ReentrantCall();

    constructor(address[] memory newValidators, uint256 _quorum) {
        require(_quorum > 0 && _quorum <= newValidators.length, "Invalid quorum");

        // Initialize arrays with zero elements at index 0
        validators.push(address(0));
        transactionIds.push(bytes32(0));

        // Set initial tick
        tick = 1;

        // Add validators
        for (uint256 i = 0; i < newValidators.length; i++) {
            address validator = newValidators[i];
            require(validator != address(0) && validator != address(this), "Invalid validator");
            require(!isValidator[validator], "Duplicate validator");

            validators.push(validator);
            validatorsReverseMap[validator] = validators.length - 1;
            validatorsAddTick[validator] = tick;
            isValidator[validator] = true;
        }

        quorum = _quorum;
    }

    modifier onlyValidator() {
        if (!isValidator[msg.sender] || validatorsRemovalTick[msg.sender] > 0) revert InvalidValidator();
        _;
    }

    modifier nonReentrant() {
        if (guard != 1) revert ReentrantCall();
        guard = 2;
        _;
        guard = 1;
    }

    modifier onlySelf() {
        require(msg.sender == address(this), "Only callable through executeTransaction");
        _;
    }

    modifier notSelf() {
        if (msg.sender == address(this)) revert InvalidCreator();
        _;
    }

    modifier validatorExists(address validator) {
        require(validator != address(0) && validator != address(this), "Invalid validator address");
        require(isValidator[validator], "Validator does not exist");
        _;
    }

    modifier validatorDoesNotExist(address validator) {
        require(validator != address(0) && validator != address(this), "Invalid validator address");
        require(!isValidator[validator], "Validator already exists");
        _;
    }

    function addValidator(address validator, uint256 newQuorum) external onlySelf {
        if (validator == address(0) || validator == address(this)) revert ZeroAddress();
        if (isValidator[validator]) revert DuplicateValidator();
        if (newQuorum == 0 || newQuorum > validators.length + 1) revert InvalidQuorum();

        validators.push(validator);
        validatorsReverseMap[validator] = validators.length - 1;
        validatorsAddTick[validator] = tick;
        validatorsRemovalTick[validator] = 0; // refresh in case of re-add
        isValidator[validator] = true;
        quorum = newQuorum;
        // Increment tick
        tick++;
    }

    function removeValidator(address validator, uint256 newQuorum) external onlySelf {
        if (validator == address(0) || validator == address(this)) revert ZeroAddress();
        if (!isValidator[validator]) revert InvalidValidator();
        if (newQuorum == 0 || newQuorum > validators.length - 1) revert InvalidQuorum();

        uint256 validatorIndex = validatorsReverseMap[validator];
        uint256 lastValidatorIndex = validators.length - 1;
        address lastValidator = validators[lastValidatorIndex];

        validators[validatorIndex] = lastValidator;
        validatorsReverseMap[lastValidator] = validatorIndex;
        validators.pop();

        delete validatorsReverseMap[validator];
        delete isValidator[validator];
        validatorsRemovalTick[validator] = tick;
        quorum = newQuorum;
        // Increment tick
        tick++;
    }

    function replaceValidator(address validator, address newValidator) external onlySelf {
        if (validator == address(0) || validator == address(this)) revert ZeroAddress();
        if (newValidator == address(0) || newValidator == address(this)) revert ZeroAddress();
        if (!isValidator[validator]) revert InvalidValidator();
        if (isValidator[newValidator]) revert DuplicateValidator();

        uint256 validatorIndex = validatorsReverseMap[validator];
        validators[validatorIndex] = newValidator;
        validatorsReverseMap[newValidator] = validatorIndex;
        validatorsAddTick[newValidator] = tick;
        isValidator[newValidator] = true;

        delete validatorsReverseMap[validator];
        delete isValidator[validator];
        validatorsRemovalTick[validator] = tick;
        // Increment tick
        tick++;
    }

    function changeQuorum(uint256 _quorum) external onlySelf {
        if (_quorum == 0 || _quorum > validators.length) revert InvalidQuorum();
        quorum = _quorum;
    }

    function transactionExists(bytes32 transactionId) external view returns (bool) {
        return _transactionExists(transactionId);
    }

    function _transactionExists(bytes32 transactionId) internal view returns (bool) {
        if (transactionId == bytes32(0)) {
            return false;
        } else if (transactions[transactionId].destination == address(0)) {
            return false;
        } else if (transactionsRemovalTick[transactionId] > 0) {
            return false;
        } else {
            return transactionsTick[transactionId] > 0
                && transactionIds[transactionIdsReverseMap[transactionId]] == transactionId;
        }
    }

    function createTransaction(
        bytes32 transactionId,
        address destination,
        uint256 value,
        bytes calldata data,
        bool hasReward
    ) public payable notSelf {
        if (tick == 0) revert InvalidTick();
        if (transactionId == bytes32(0)) revert InvalidTransactionId();
        if (destination == address(0)) revert InvalidDestination();
        if (transactionsRemovalTick[transactionId] > 0) revert TransactionAlreadyRemoved();
        if (_transactionExists(transactionId)) revert TransactionAlreadyExists();
        require(msg.value >= value + (hasReward ? FEE : 0), "Insufficient value");

        Transaction storage txn = transactions[transactionId];
        txn.destination = destination;
        txn.value = value;
        txn.data = data;
        txn.hasReward = hasReward;
        txn.creator = msg.sender;

        transactionIds.push(transactionId);
        transactionIdsReverseMap[transactionId] = transactionIds.length - 1;
        transactionsTick[transactionId] = tick;

        if (hasReward) {
            pendingRewardsPot += FEE;
        }
        transactionsTotalValue += value;

        // Auto-confirm if creator is validator
        if (isValidator[msg.sender]) {
            confirmations[transactionId][msg.sender] = true;
            confirmationsTick[transactionId][msg.sender] = tick;
        }
        // Increment tick
        tick++;
    }

    function voteForTransaction(bytes32 transactionId) external onlyValidator nonReentrant {
        if (!_transactionExists(transactionId)) revert TransactionNotFound();
        bool alreadyConfirmed = confirmations[transactionId][msg.sender]
            && confirmationsTick[transactionId][msg.sender] >= transactionsTick[transactionId]
            && confirmationsTick[transactionId][msg.sender] > validatorsRemovalTick[msg.sender];
        if (alreadyConfirmed) revert TransactionAlreadyConfirmed();

        confirmations[transactionId][msg.sender] = true;
        confirmationsTick[transactionId][msg.sender] = tick;
        // If enough confirmations, execute transaction
        if (isConfirmed(transactionId)) {
            executeTransaction(transactionId);
        }
        // Question: should voting increment tick??
        tick++;
    }

    function executeTransaction(bytes32 transactionId) public {
        if (!_transactionExists(transactionId)) revert TransactionNotFound();
        if (!isConfirmed(transactionId)) revert TransactionNotConfirmed();
        Transaction storage txn = transactions[transactionId];
        if (txn.executed) revert TransactionAlreadyExecuted();
        require(address(this).balance >= txn.value + confirmedRewardsPot + pendingRewardsPot, "Insufficient balance");

        tick++; // should this tick?? tbd

        txn.executed = true;

        if (txn.hasReward) {
            confirmedRewardsPot += FEE;
            pendingRewardsPot -= FEE;
        }

        transactionsTotalValue -= txn.value;

        (bool success,) = txn.destination.call{value: txn.value}(txn.data);
        require(success, "Transaction failed");
    }

    function removeTransaction(bytes32 transactionId) external onlySelf {
        if(!_transactionExists(transactionId)) revert TransactionNotFound();
        Transaction storage txn = transactions[transactionId];
        require(!txn.executed, "Transaction already executed");

        uint256 txIndex = transactionIdsReverseMap[transactionId];
        uint256 lastTxIndex = transactionIds.length - 1;
        bytes32 lastTxId = transactionIds[lastTxIndex];

        transactionIds[txIndex] = lastTxId;
        transactionIdsReverseMap[lastTxId] = txIndex;
        transactionIds.pop();

        // Calculate refund amount
        uint256 refundAmount = txn.value;
        if (txn.hasReward) {
            pendingRewardsPot -= FEE;
            refundAmount += FEE;
        }
        transactionsTotalValue -= txn.value;

        // Remove all confirmations for this transactionId
        for (uint256 i = 1; i < validators.length; i++) {
            confirmations[transactionId][validators[i]] = false;
        }

        // Store creator before deletion
        address creator = txn.creator;

        delete transactions[transactionId];
        delete transactionIdsReverseMap[transactionId];
        delete transactionsTick[transactionId];
        transactionsRemovalTick[transactionId] = tick;
        // Increment tick
        tick++;
        // Refund the creator
        (bool success,) = creator.call{value: refundAmount}("");
        require(success, "Refund failed");
    }

    function isConfirmed(bytes32 transactionId) public view returns (bool) {
        Transaction storage txn = transactions[transactionId];
        if (txn.destination == address(0)) return false;

        uint256 count = _confirmationCount(transactionId);
        return count >= quorum;
    }

    function getDataOfTransaction(bytes32 id) external view returns (bytes memory data) {
        return transactions[id].data;
    }

    function hash(bytes memory data) external pure returns (bytes32 result) {
        return keccak256(data);
    }

    function getConfirmationCount(bytes32 transactionId) external view returns (uint256 count) {
        return _confirmationCount(transactionId);
    }

    function _confirmationCount(bytes32 transactionId) internal view returns (uint256 count) {
        for (uint256 i = 1; i < validators.length; i++) {
            if (
                confirmations[transactionId][validators[i]]
                    && confirmationsTick[transactionId][validators[i]] > transactionsTick[transactionId]
                    && confirmationsTick[transactionId][validators[i]] > validatorsAddTick[validators[i]]
            ) {
                // && validatorsAddTick[validators[i]] <= transactionsTick[transactionId]
                // && (
                //     validatorsRemovalTick[validators[i]] == 0
                //         && confirmationsTick[transactionId][validators[i]] < validatorsRemovalTick[validators[i]]
                // )

                count++;
            }
        }
    }

    function distributeRewards() external {
        require(confirmedRewardsPot > 0, "No rewards to distribute");
        require(validators.length > 1, "No validators");

        uint256 validatorCount = validators.length - 1; // Exclude index 0
        uint256 rewardPerValidator = confirmedRewardsPot / validatorCount;
        // Update confirmedRewardsPot to hold only the remainder
        confirmedRewardsPot = confirmedRewardsPot % validatorCount;
        // Distribute rewards to all validators except index 0
        for (uint256 i = 1; i < validators.length; i++) {
            (bool success,) = validators[i].call{value: rewardPerValidator}("");
            require(success, "Reward transfer failed");
        }
    }
}
