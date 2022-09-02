// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint _nftId
    ) external;
}

contract DutchAuction {
    
    //售卖人
    address payable  public seller;
    // 拍卖时长
    uint private constant DURATION = 7 days;
    // 拍卖开始
    uint public immutable starAt;
    // 拍卖结束
    uint public immutable expiresAt;
    // 拍卖流失效率
    uint public immutable discountRate;
    // nft 价格
    uint public  immutable startingPrice;

    IERC721 public immutable nft;

    uint public immutable nftid;

    constructor(uint _discountRate, uint _startingPrice, IERC721 _nft, uint _nftid) {

        seller = payable(msg.sender);
        starAt = block.timestamp;
        expiresAt = starAt + DURATION;
        startingPrice = _startingPrice;
        discountRate = _discountRate;

        require(_startingPrice >= _discountRate * DURATION, "auction expired");
        nft = IERC721(_nft);
        nftid = _nftid;
    }

    function getPrice() public view returns (uint) {
        //获取当前的拍卖价格
        uint timeElapsed = block.timestamp - starAt;
        uint discount = timeElapsed * discountRate;
        return startingPrice - discount;
    }

    function buy() public payable {

        // 判断当前拍卖是否超时
        require(block.timestamp < expiresAt, "action expired");
        uint price = getPrice();

        // 判断用户账户余额是否大于拍卖价格
        require(msg.value >= price, "ETH < price");
        //进行NFT转让
        nft.transferFrom(seller, msg.sender, nftid);
        // 转账多余的钱进行退款给用户
        uint refund = msg.value - price;
        if(refund > 0) {
            payable (msg.sender).transfer(refund);
        }
        // 购买的金额转账给拍卖方
        selfdestruct(seller);
    }


}