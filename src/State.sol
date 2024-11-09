pragma solidity ^0.8.7;

abstract contract State {
    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
        bool hasReward;
        address creator;
    }

    /// @dev Current set of validators, i.e. addresses that control the
    /// contract.
    address[] public validators;
    mapping(address => uint256) public validatorsReverseMap;
    mapping(address => uint256) public validatorsAddTick;
    mapping(address => uint256) public validatorsRemovalTick;

    /// @dev Mapping kept in sync with validator list for fast lookups.
    mapping(address => bool) public isValidator;

    /// @dev Number of validator votes needed to execute a validator-majority
    /// only action.
    uint256 public quorum;

    mapping(bytes32 => Transaction) public transactions;
    mapping(bytes32 => uint256) public transactionsTick;
    mapping(bytes32 => uint256) public transactionsRemovalTick;
    /// @dev List kept in sync to not lose information on mapping keys.
    bytes32[] public transactionIds;
    mapping(bytes32 => uint256) public transactionIdsReverseMap;

    /// @dev Mapping to keep track of validator votes for a transaction
    /// proposal.
    mapping(bytes32 => mapping(address => bool)) public confirmations;
    mapping(bytes32 => mapping(address => uint256)) public confirmationsTick;

    uint256 public constant FEE = 0.1 ether;

    /// @dev Describes how much of bridge's balance is available to be
    /// distributed among validators.
    uint256 public confirmedRewardsPot;
    uint256 public pendingRewardsPot;
    uint256 public transactionsTotalValue;

    uint256 public tick;
    uint256 public guard;
}
