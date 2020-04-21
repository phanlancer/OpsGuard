pragma solidity >=0.4.19 <0.6.5;

import "../OpsAllocation.sol";


contract TestAllocation is OpsAllocation {
    constructor(address _token, address _ico, address _growthTokensAddress)
        public
        OpsAllocation(_token, _ico, _growthTokensAddress)
    {}

    function setLastReleaseTime(uint256 _val) public {
        lastReleaseTime = _val;
    }

    function setGrowthTokensLastClaim(uint256 _val) public {
        growthTokensLastClaim = _val;
    }
}
