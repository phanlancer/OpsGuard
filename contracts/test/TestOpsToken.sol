pragma solidity >=0.4.19 <0.6.5;

import "../OpsToken.sol";


contract TestOpsToken is OpsToken {
    constructor(address _bountyAddress, bool _locked)
        public
        OpsToken(_bountyAddress, _locked)
    {}

    function testSetFreezing(bool _isFrozen) public {
        transferFrozen = _isFrozen;
    }
}
