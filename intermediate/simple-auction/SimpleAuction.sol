// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleAuction {
    struct Auction {
        address payable owner;
        address payable highestBidder;
        uint256 highestBid;
        uint256 endTime;
        bool ended;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(address => uint256) public pendingReturns; 
    uint256 public auctionCount;

    function createAuction(uint256 duration) public {
        require(duration > 0, "Duration must be greater than zero");
        auctionCount++;
        auctions[auctionCount] = Auction({
            owner: payable(msg.sender),
            highestBidder: payable(address(0)),
            highestBid: 0,
            endTime: block.timestamp + duration,
            ended: false
        });
    }

    function bid(uint256 auctionId) public payable {
        Auction storage auction = auctions[auctionId];
        require(msg.sender != auction.owner, "Owner cannot bid");
        require(block.timestamp < auction.endTime, "Auction has ended");
        require(!auction.ended, "Auction already ended");
        require(msg.value > auction.highestBid, "Bid must be higher");

        if (auction.highestBid > 0) {
            pendingReturns[auction.highestBidder] += auction.highestBid;
        }

        auction.highestBidder = payable(msg.sender);
        auction.highestBid = msg.value;
    }

    function withdraw() public {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "No funds to withdraw");
        pendingReturns[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Withdraw failed");
    }

    function endAuction(uint256 auctionId) public {
        Auction storage auction = auctions[auctionId];
        require(msg.sender == auction.owner, "Only owner can end");
        require(block.timestamp >= auction.endTime, "Auction not ended yet");
        require(!auction.ended, "Already ended");

        auction.ended = true;

        if (auction.highestBid > 0) {
            (bool success,) = auction.owner.call{value: auction.highestBid}("");
            require(success, "Transfer to owner failed");
        }
    }
}
