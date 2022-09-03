// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 英式拍卖

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract EnglishAuction {

    IERC721 public immutable nft;
    uint public immutable nftid;
    address payable public immutable seller;

    // 起拍时间
    uint public startTime;
    // 结束时间
    uint public endTiem;
    // 是否开始拍卖
    bool public isStart;
    // 是否结束拍卖
    bool public isEnd;
    //最高拍卖价格
    uint256 public bidHighPrice;
    // 最高拍卖地址
    address public bidHighAddress;

    // 保存拍卖地址的钱
    mapping (address => uint256) public  bids;

    constructor(IERC721 _nft, uint _nftid, uint256 bidPrice) payable {
        nft = IERC721(_nft);
        nftid = _nftid;
        seller = payable (msg.sender);

        bidHighPrice = bidPrice;
    }

    function start() public {
        require(!isStart, "bid start yes");
        require(seller == msg.sender);
        isStart = true;

        // 把要拍卖的nft转账给合约
        nft.transferFrom(seller, address(this), nftid);

        endTiem = block.timestamp + 7 days;

    }

    function bid() public payable {
        require(isStart, "bid start yes");
        require(block.timestamp < endTiem);

        // 拍卖账号的钱需要大于拍卖价格
        require(msg.value >= bidHighPrice);

        // 判断竞拍地址是否为0地址
        if (bidHighAddress != address(0)) {
            bids[bidHighAddress] += bidHighPrice;
        }
        bidHighAddress = msg.sender;
        bidHighPrice = msg.value;
    }

    function whthdraw() public payable {

        // 获取竞拍当时的金额
        require(msg.sender != address(0));
        uint amount = bids[msg.sender];
        // 竞拍账号保存的金额重置金额为0
        bids[msg.sender] = 0;
        payable (msg.sender).transfer(amount);
    }

    function endBid() public {
        require(isStart);
        // 拍卖已经结束
        require(block.timestamp >= endTiem);
        require(!isEnd);
        isEnd = true;

        // 拍卖结束进行nft转移
        if (bidHighAddress != address(0)) {
            nft.transferFrom(address(this), bidHighAddress, nftid);
            // 价高者金额转账给nft售卖者
            seller.transfer(bidHighPrice);
        } else {
            nft.transferFrom(address(this), seller, nftid);
        }
    } 




}