pragma solidity >=0.4.19 <0.6.5;
import "../Multivest.sol";


contract TestMultivest is Multivest {
    constructor(address allowedMultivest) public Multivest() {
        setAllowedMultivest(allowedMultivest);
    }

    function buy(address _address, uint256 _value) internal returns (bool) {
        _address = _address;
        _value = _value;
    }
}
