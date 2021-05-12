// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SmartWallet {
    mapping(address => uint256) private _balances;
    mapping(address => bool) private _users_address;
    mapping(address => bool) private _vips_address;
    mapping(address => mapping(address => uint256)) private _delegations;
    mapping(address => bytes32) private _private_keys;
    uint256 private _gain;
    uint256 private _nb_address;
    uint256 private _tax;
    address private _author;
    uint256 private _vip_price = 10 ^ 15;
    bytes32 private _basic_bytes = 0x0;

    event Deposit(address indexed account, uint256 amount);
    event Withdrew(address indexed account, uint256 amount);
    event Transfer(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );
    event DelegationTransfer(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );
    event BuyVip(address indexed account);

    constructor(uint256 tax_) {
        _author = msg.sender;
        _tax = tax_;
        _vips_address[msg.sender] = true;
        _addAddress(msg.sender);
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
        emit Deposit(msg.sender, msg.value);
        _balances[msg.sender] += msg.value;
        _addAddress(msg.sender);
    }

    function withdraw() public {
        uint256 amount = _balances[msg.sender];
        require(
            _balances[msg.sender] > 0,
            "SmartWallet: can not withdraw 0 ether"
        );
        emit Withdrew(msg.sender, amount);
        _balances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    function withdrawAllBalance() public onlyAuthor() {
        payable(msg.sender).transfer(address(this).balance);
    }

    function _addAddress(address account) private {
        if (!_users_address[account]) {
            _users_address[account] = true;
            _nb_address++;
            _getPrivateKey(account);
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

    function inTransfer(address account, uint256 amount) public {
        uint256 _calcTax =
            _vips_address[msg.sender] ? 0 : (amount * _tax) / 100;
        require(
            checkUser(account),
            "SmartWallet: this user don't have signed up"
        );
        require(
            _balances[msg.sender] >= amount + _calcTax,
            "SmartWallet: can not transfer more than actual balance"
        );
        emit Transfer(msg.sender, account, amount);
        if (_calcTax != 0) emit Transfer(msg.sender, _author, _calcTax);
        _balances[msg.sender] -= amount + _calcTax;
        _balances[account] += amount;
        _balances[_author] += _calcTax;
        _gain += _calcTax;
    }

    function privateTransfer(
        address sender,
        address receiver,
        uint256 amount
    ) public onlyAuthor() {
        require(
            _balances[sender] >= amount,
            "SmartWallet: sender can not send more than actual balance"
        );
        emit Transfer(sender, receiver, amount);
        _balances[sender] -= amount;
        _balances[receiver] += amount;
    }

    function setTax(uint256 amount) public onlyAuthor() {
        require(
            amount <= 100,
            "SmartWallet: can not set a tax higher than 100"
        );
        _tax = amount;
    }

    function buyVip() public {
        require(!_vips_address[msg.sender], "SmartWallet: user already vip");
        require(
            _balances[msg.sender] >= _vip_price,
            "SmartWallet: user can not buy Vip, balance too low"
        );
        emit BuyVip(msg.sender);
        _balances[msg.sender] -= _vip_price;
        _balances[_author] += _vip_price;
        _vips_address[msg.sender] = true;
    }

    function removeVip(address account) public onlyAuthor() {
        require(_vips_address[account], "SmartWallet: not a Vip user");
        _balances[_author] -= _vip_price;
        _balances[account] += _vip_price;
        _vips_address[account] = false;
    }

    function setDelegation(address account, uint256 amount) public {
        require(
            _vips_address[account],
            "SmartWallet: can only delegate to a Vip user"
        );
        emit DelegationTransfer(msg.sender, account, amount);
        _balances[msg.sender] -= amount;
        _delegations[account][msg.sender] += amount;
    }

    function withdrawDelegation(address account) public {
        emit DelegationTransfer(
            account,
            msg.sender,
            _delegations[account][msg.sender]
        );
        _balances[msg.sender] += _delegations[account][msg.sender];
        _delegations[account][msg.sender] = 0;
    }

    function _getPrivateKey(address account) private {
        _private_keys[account] = keccak256(abi.encodePacked(account));
    }

    function userGetPrivateKey() public {
        deletePrivateKey(msg.sender);
        _getPrivateKey(msg.sender);
    }

    function deletePrivateKey(address account) public {
        _private_keys[account] = _basic_bytes;
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

    function checkUser(address account) public view returns (bool) {
        return _users_address[account];
    }

    function checkVip(address account) public view returns (bool) {
        return _vips_address[account];
    }

    function checkDelegation(address account) public view returns (uint256) {
        return _delegations[account][msg.sender];
    }

    function checkPrivateKey() public view returns (bytes32) {
        require(
            _private_keys[msg.sender] != _basic_bytes,
            "SmartWallet: private key not activate"
        );
        return _private_keys[msg.sender];
    }
}
