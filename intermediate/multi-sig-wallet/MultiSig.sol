// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    struct Transaction {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 numApprovals;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not owner");
        _;
    }

    modifier txExists(uint256 _txId) {
        require(_txId < transactions.length, "Tx does not exist");
        _;
    }

    modifier notApproved(uint256 _txId) {
        require(!approved[_txId][msg.sender], "Already approved");
        _;
    }

    modifier notExecuted(uint256 _txId) {
        require(!transactions[_txId].executed, "Already executed");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "No owners");
        require(_required > 0 && _required <= _owners.length, "Invalid required number");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        required = _required;
    }

    receive() external payable {}

    function submit(address _to, uint256 _value, bytes memory _data) external onlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false, numApprovals: 0}));
    }

    function approve(uint256 _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId) {
        approved[_txId][msg.sender] = true;
        transactions[_txId].numApprovals += 1;
    }

    function revoke(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        require(approved[_txId][msg.sender], "Not approved yet");
        approved[_txId][msg.sender] = false;
        transactions[_txId].numApprovals -= 1;
    }

    function execute(uint256 _txId) external onlyOwner txExists(_txId) notExecuted(_txId) {
        Transaction storage transaction = transactions[_txId];
        require(transaction.numApprovals >= required, "Not enough approvals");

        transaction.executed = true;
        (bool success,) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "Transaction failed");
    }

    function getTransaction(uint256 _txId)
        external
        view
        returns (address to, uint256 value, bytes memory data, bool executed, uint256 numApprovals)
    {
        Transaction storage transaction = transactions[_txId];
        return (transaction.to, transaction.value, transaction.data, transaction.executed, transaction.numApprovals);
    }
}
