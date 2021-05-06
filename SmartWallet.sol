// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SmartWallet {
    mapping(address => uint256) private _balances;
    uint256 public _tax;
    address public _author;
    uint256 private _gain;

    constructor(uint256 tax_) {
        _author = msg.sender;
        _tax = tax_;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function deposit() public payable {
        _balances[msg.sender] += msg.value;
    }

    function withdrawAmount(uint256 amount) public {
        require(
            _balances[msg.sender] >= amount,
            "SmartWallet: can not withdraw more than actual balance"
        );
        _balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function transfer(address account, uint256 amount) public {
        require(
            _balances[msg.sender] >= amount,
            "SmartWallet: can not transfer more than actual balance"
        );
        uint256 _calcTax = (amount * _tax) / 100;
        _balances[msg.sender] -= amount;
        _balances[account] += amount - _calcTax;
        _balances[_author] += _calcTax;
        _gain += _calcTax;
    }

    function setTax(uint256 amount) public {
        require(
            amount <= 100,
            "SmartWallet: can not set a tax not including between 0 and 100"
        );
        _tax = amount;
    }

    function withdraw() public {
        require(
            _balances[msg.sender] > 0,
            "SmartWallet: can not withdraw 0 ether"
        );
        uint256 amount = _balances[msg.sender];
        _balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function total() public view returns (uint256) {
        return address(this).balance;
    }

    function revealGain() public view returns (uint256) {
        return _gain;
    }
}
