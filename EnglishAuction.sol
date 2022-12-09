// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint tokenId) external;

    function transferFrom(address, address, uint) external;
}

contract EnglishAuction {
    event Start();
    event Bid(address indexed sender, uint amount);
    event Withdraw(address indexed bidder, uint amount);
    event End(address winner, uint amount);

    IERC721 public nft;
    uint public nftId;

    address payable public seller;
    uint public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) public bids;

    constructor(address _nft, uint _nftId, uint _startingBid) {
        nft = IERC721(_nft);
        nftId = _nftId;
        seller = payable(msg.sender);
        highestBid = _startingBid;
    }

    //1 .fucntion to start bidding by seller
    function start() external {
        require(!started, "started");
        require(msg.sender == seller, "you are not seller");

        //seller wil send its nft to this contract
        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        endAt = block.timestamp + 7 days;
        emit Start();
    }

    //2. bidding function
    function bidding() external payable {
        require(started, "bidding not started yet");
        require(block.timestamp < endAt, "bidding is ended");
        require(msg.value > highestBid, "value is less then highestBid");

        //if highestBidder is not the seller then update bidding price
        if (highestBidder != address(0)) {
            bids[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit Bid(msg.sender, msg.value);
    }

    //3.  if someone wants to withdraw from bidding
    function withdraw() external payable {
        require(msg.value != 0, "can not withdraw");
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    //4.function to end bidding
    function end() external {
        require(started, "not started yet");
        require(block.timestamp >= endAt, "bidding is not ended yet");
        require(!ended, "ended");

        ended = true;

        // if nft is bidded transfer nft ownership from contract to the highestBidder and transfer money to seller
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }

        emit End(highestBidder, highestBid);
    }
}
