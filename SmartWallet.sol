// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SmartWallet {
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _users_address;
    uint256 private _gain;
    uint256 public _nb_address;
    uint256 public _tax;
    address public _author;

    constructor(uint256 tax_) {
        _author = msg.sender;
        _tax = tax_;
        _users_address[msg.sender] = true;
        _nb_address++;
    }

    modifier onlyAuthor() {
        require(
            msg.sender == _author,
            "SmartWallet: Only the author can use this function"
        );
        _;
    }

    // Write
    function deposit() public payable {
        _balances[msg.sender] += msg.value;
        addAddress(msg.sender);
    }

    function withdrawAmount(uint256 amount) public {
        require(
            _balances[msg.sender] >= amount,
            "SmartWallet: can not withdraw more than actual balance"
        );
        _balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    function inTransfer(address account, uint256 amount) public {
        require(
            checkAddress(account),
            "SmartWallet: this user don't have signed up"
        );
        require(
            _balances[msg.sender] <= amount,
            "SmartWallet: can not transfer more than actual balance"
        );
        uint256 _calcTax = (amount * _tax) / 100;
        _balances[msg.sender] -= amount;
        _balances[account] += amount - _calcTax;
        _balances[_author] += _calcTax;
        _gain += _calcTax;
    }

    function setTax(uint256 amount) public onlyAuthor() {
        require(
            amount <= 100,
            "SmartWallet: can not set a tax higher than 100"
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

    function addAddress(address _addr) private {
        if (!checkAddress(_addr)) {
            _users_address[_addr] = true;
            _nb_address++;
        }
    }

    function closeAccount() public {
        require(
            msg.sender != _author,
            "SmartWallet: author can not close his account"
        );
        require(
            _balances[msg.sender] == 0,
            "SmartWallet: withdraw needed before close an account"
        );
        _users_address[msg.sender] = false;
        _nb_address--;
    }

    // Read
    function checkBalance() public view returns (uint256) {
        return _balances[msg.sender];
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function total() public view returns (uint256) {
        return address(this).balance;
    }

    function revealGain() public view returns (uint256) {
        return _gain;
    }

    function checkAddress(address _addr) public view returns (bool) {
        return _users_address[_addr];
    }
}
