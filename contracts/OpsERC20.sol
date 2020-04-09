pragma solidity >=0.4.19 <0.6.5;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "./Ownable.sol";


contract OpsERC20 is StandardToken, Ownable {
    /* Public variables of the token */
    uint256 public creationBlock;

    uint8 public decimals;

    string public name;

    string public symbol;

    string public standard;

    bool public locked;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        uint256 _totalSupply,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    ) public {
        standard = "ERC20 0.1";
        locked = _locked;
        totalSupply_ = _totalSupply;

        if (_transferAllSupplyToOwner) {
            balances[msg.sender] = totalSupply_;
        } else {
            balances[this] = totalSupply_;
        }
        name = _tokenName;
        // Set the name for display purposes
        symbol = _tokenSymbol;
        // Set the symbol for display purposes
        decimals = _decimalUnits;
        // Amount of decimals for display purposes
        creationBlock = block.number;
    }

    /* public methods */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(locked == false, "");
        return super.transfer(_to, _value);
    }

    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        if (locked) {
            return false;
        }
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue)
        public
        returns (bool success)
    {
        if (locked) {
            return false;
        }
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        returns (bool success)
    {
        if (locked) {
            return false;
        }
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function transferFrom(address _from, address _to, uint256 _value)
        public
        returns (bool success)
    {
        if (locked) {
            return false;
        }

        return super.transferFrom(_from, _to, _value);
    }
}
