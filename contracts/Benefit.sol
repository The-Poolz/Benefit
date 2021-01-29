// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

import "./IPozBenefit.sol";
import "./IStaking.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract Benefit is IPOZBenefit, Ownable {
    constructor() public {
        MinHold = 1;
        ChecksCount = 0;
    }

    struct BalanceCheckData {
        bool IsToken; //token or staking contract address
        address ContractAddress; // the address of the token or th staking
    }

    uint256 public MinHold; //minimum total holding to be POOLZ Holder
    mapping(uint256 => BalanceCheckData) CheckList; //All the contracts to get the sum
    uint256 public ChecksCount; //Total Checks to make

    function SetMinHold(uint256 _MinHold) public onlyOwner {
        require(_MinHold > 0, "Must be more then 0");
        MinHold = _MinHold;
    }

    function AddNewBalanceCheckData(address _ContractAddress, bool _IsToken)
        public
        onlyOwner
    {
        CheckList[ChecksCount] = BalanceCheckData(_IsToken, _ContractAddress);
        ChecksCount++;
    }

    function RemoveLastBalanceCheckData() public onlyOwner {
        require(ChecksCount > 0, "Can't remove from none");
        ChecksCount--;
    }

    function CheckBalance(address _Token, address _Subject)
        internal
        view
        returns (uint256)
    {
        return ERC20(_Token).balanceOf(_Subject);
    }

    function CheckStaking(address _Contract, address _Subject)
        internal
        view
        returns (uint256)
    {
        return IStaking(_Contract).stakeOf(_Subject);
    }

    function IsPOZHolder(address _Subject) external view returns (bool) {
         return CalcTotal(_Subject) >= MinHold;
    }

    function CalcTotal(address _Subject) public view returns (uint256) {
        uint256 Total = 0;
        for (uint256 index = 0; index < ChecksCount; index++) {
            Total =
                Total +
                (
                    CheckList[index].IsToken
                        ? CheckBalance(
                            CheckList[index].ContractAddress,
                            _Subject
                        )
                        : CheckStaking(
                            CheckList[index].ContractAddress,
                            _Subject
                        )
                );
        }
        return Total;
    }
}
