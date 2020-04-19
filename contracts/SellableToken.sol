pragma solidity >=0.4.19 <0.6.5;

import "./OpsToken.sol";
import "./Multivest.sol";


contract SellableToken is Multivest {
    OpsToken public token;

    uint256 public constant DECIMALS = 18;

    uint256 public minPurchase = 1000000; //10usd * 10 ^ 5

    uint256 public softCap = 300000000000; //usd * 10 ^ 5
    uint256 public hardCap = 1500000000000; //usd * 10 ^ 5

    uint256 public compensationAmount = 5100000000; //usd * 10 ^ 5
    uint256 public compensatedAmount;

    uint256 public startTime;
    uint256 public endTime;

    uint256 public maxTokenSupply;

    uint256 public soldTokens;

    uint256 public collectedEthers;

    uint256 public priceUpdateAt;

    address public etherHolder;

    address public compensationAddress;

    uint256 public collectedUSD;

    uint256 public etherPriceInUSD; //$753.25  75325000

    mapping(address => uint256) public etherBalances;

    mapping(address => bool) public whitelist;

    Tier[] public tiers;

    struct Tier {
        uint256 maxAmount;
        uint256 price;
        uint256 startTime;
        uint256 endTime;
    }

    event WhitelistSet(address indexed contributorAddress, bool isWhitelisted);

    event Refund(address _holder, uint256 _ethers, uint256 _tokens);

    constructor(
        address _token,
        address _etherHolder,
        address _compensationAddress,
        uint256 _etherPriceInUSD,
        uint256 _maxTokenSupply
    ) public Multivest() {
        require(_token != address(0), "");
        token = OpsToken(_token);

        require(
            _etherHolder != address(0) && _compensationAddress != address(0),
            ""
        );
        etherHolder = _etherHolder;
        compensationAddress = _compensationAddress;
        require(
            (_maxTokenSupply == uint256(0)) ||
                (_maxTokenSupply <= token.maxSupply()),
            ""
        );

        etherPriceInUSD = _etherPriceInUSD;
        maxTokenSupply = _maxTokenSupply;

        priceUpdateAt = block.timestamp;
    }

    receive() external payable {
        require(
            true == whitelist[msg.sender] && buy(msg.sender, msg.value) == true,
            ""
        );
    }

    function setTokenContract(address _token) public onlyOwner {
        require(_token != address(0), "");
        token = OpsToken(_token);
    }

    function isActive() public view returns (bool) {
        if (maxTokenSupply > uint256(0) && soldTokens == maxTokenSupply) {
            return false;
        }

        return withinPeriod();
    }

    function withinPeriod() public view returns (bool) {
        return block.timestamp >= startTime && block.timestamp <= endTime;
    }

    function setEtherHolder(address _etherHolder) public onlyOwner {
        if (_etherHolder != address(0)) {
            etherHolder = _etherHolder;
        }
    }

    function setCompensationAddress(address _compensationAddress)
        public
        onlyOwner
    {
        if (_compensationAddress != address(0)) {
            compensationAddress = _compensationAddress;
        }
    }

    function updateWhitelist(address _address, bool isWhitelisted)
        public
        onlyOwner
    {
        whitelist[_address] = isWhitelisted;
        WhitelistSet(_address, isWhitelisted);
    }

    function mint(address _address, uint256 _tokenAmount)
        public
        onlyOwner
        returns (uint256)
    {
        return mintInternal(_address, _tokenAmount);
    }

    function setEtherPriceInUSD(string _price) public onlyOwner {
        setEtherInUSDInternal(_price);
    }

    function setEtherInUSD(string _price)
        public
        onlyAllowedMultivests(msg.sender)
    {
        setEtherInUSDInternal(_price);
    }

    // set ether price in USD with 5 digits after the decimal point
    //ex. 308.75000
    //for updating the price through  multivest
    function setEtherInUSDInternal(string _price) internal {
        bytes memory bytePrice = bytes(_price);
        uint256 dot = bytePrice.length.sub(uint256(6));

        // check if dot is in 6 position  from  the last
        require(0x2e == uint256(bytePrice[dot]));

        uint256 newPrice = uint256(10**23).div(parseInt(_price, 5));

        require(newPrice > 0);

        etherPriceInUSD = parseInt(_price, 5);

        priceUpdateAt = block.timestamp;
    }

    function mintInternal(address _address, uint256 _tokenAmount)
        internal
        returns (uint256)
    {
        uint256 mintedAmount = token.mint(_address, _tokenAmount);

        require(mintedAmount == _tokenAmount);

        mintedAmount = mintedAmount.add(
            token.mint(compensationAddress, _tokenAmount.mul(5).div(1000))
        );

        soldTokens = soldTokens.add(_tokenAmount);
        if (maxTokenSupply > 0) {
            require(maxTokenSupply >= soldTokens);
        }

        return _tokenAmount;
    }

    function transferEthersInternal() internal {
        if (collectedUSD >= softCap) {
            if (compensatedAmount < compensationAmount) {
                uint256 amount = uint256(1 ether)
                    .mul(compensationAmount.sub(compensatedAmount))
                    .div(etherPriceInUSD);
                compensationAddress.transfer(amount);
                compensatedAmount = compensationAmount;
            }

            etherHolder.transfer(this.balance);
        }
    }

    function parseInt(string _a, uint256 _b) internal pure returns (uint256) {
        bytes memory bresult = bytes(_a);
        uint256 mintt = 0;
        bool decimals = false;
        for (uint256 i = 0; i < bresult.length; i++) {
            if ((bresult[i] >= 48) && (bresult[i] <= 57)) {
                if (decimals) {
                    if (_b == 0) break;
                    else _b--;
                }
                mintt *= 10;
                mintt += uint256(bresult[i]) - 48;
            } else if (bresult[i] == 46) decimals = true;
        }
        if (_b > 0) mintt *= 10**_b;
        return mintt;
    }
}
