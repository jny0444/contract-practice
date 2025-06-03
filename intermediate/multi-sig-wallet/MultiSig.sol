// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract MultiSig {
    address[] public owners;
    uint256 public constant MIN_SIGNATURES = 2;

    mapping(address => bool) public isOwner;

    struct Transaction {
        address to;
        uint256 value;
        bytes32 data;
        bool executed;
        uint256 confirmations;
    }

    Transaction[] public transactions;

    constructor(address[] memory _owners) {
        require(_owners.length >= MIN_SIGNATURES, "Not enough owners");
        owners = _owners;
        for (uint256 i = 0; i < _owners.length; i++) {
            require(_owners[i] != address(0), "Owner cannot be zero address");
            require(!isOwner[_owners[i]], "Duplicate owner");
            isOwner[_owners[i]] = true;
        }
    }

    function submitTransaction(address _to, uint256 _value, bytes32 _data) public {
        require(isOwner[msg.sender], "Only owners can submit transactions");
        require(_to != address(0), "Invalid recipient address");
        require(_value > 0, "Transaction value must be greater than zero");
        require(_data.length > 0, "Transaction data cannot be empty");
        require(_to != address(this), "Cannot send to self");

        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false, confirmations: 0}));
    }
}
