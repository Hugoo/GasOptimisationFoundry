// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract GasContract {
    address[5] public administrators;

    mapping(address => uint256) public balances;
    mapping(address => uint256) public whitelist;

    mapping(address => uint256) private whitelistTransfer;

    event AddedToWhitelist(address userAddress, uint256 tier);
    event WhiteListTransfer(address indexed);

    constructor(address[] memory _admins, uint256 _totalSupply) {
        balances[msg.sender] = _totalSupply;

        for (uint256 ii = 0; ii < administrators.length; ii++) {
            administrators[ii] = _admins[ii];
        }
    }

    function checkForAdmin(address _user) public view returns (bool admin_) {
        for (uint256 ii = 0; ii < administrators.length; ii++) {
            if (administrators[ii] == _user) {
                return true;
            }
        }
        return false;
    }

    function balanceOf(address _user) public view returns (uint256 balance_) {
        return balances[_user];
    }

    function transfer(address _recipient, uint256 _amount, string calldata) public {
        _transfer(msg.sender, _recipient, _amount);
    }

    function addToWhitelist(address _userAddrs, uint256 _tier) public {
        if (!checkForAdmin(msg.sender)) {
            revert();
        }

        if (_tier > 254) {
            revert();
        }

        whitelist[_userAddrs] = _tier > 3 ? 3 : _tier;

        emit AddedToWhitelist(_userAddrs, _tier);
    }

    function whiteTransfer(address _recipient, uint256 _amount) public {
        uint256 whitelistAmount = whitelist[msg.sender];
        if (whitelistAmount == 0) {
            revert();
        }

        whitelistTransfer[msg.sender] = _amount;

        _transfer(msg.sender, _recipient, _amount);
        _transfer(_recipient, msg.sender, whitelistAmount);

        emit WhiteListTransfer(_recipient);
    }

    function getPaymentStatus(address sender) public view returns (bool, uint256) {
        return (true, whitelistTransfer[sender]);
    }

    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        balances[_sender] -= _amount;
        balances[_recipient] += _amount;
    }
}
