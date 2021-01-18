// stakeOf(address account) public view returns (uint256)
// SPDX-License-Identifier: MIT

pragma solidity <0.5.8;

interface IStaking {
    function stakeOf(address account) public view returns (uint256) ;
}
