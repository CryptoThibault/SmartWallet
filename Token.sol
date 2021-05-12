// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    uint256 private _price;
    uint256 private _supply;
    uint256 private _contractSupply;
    uint256 private _maxSupply;

    constructor(uint256 inicialSupply) ERC20("Token", "TKN") {
        _supply = inicialSupply;
        _contractSupply = inicialSupply;
        _maxSupply = inicialSupply;
    }

    function buy(uint256 amount) public {
        _contractSupply += amount;
        payable(msg.sender).transfer(amount);
    }

    function sell() public payable {
        _contractSupply += msg.value;
    }

    function getBetterPrice() private {}

    function allSupply() public view returns (uint256) {
        return _supply;
    }

    function contractSupply() public view returns (uint256) {
        return _contractSupply;
    }

    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }
}
