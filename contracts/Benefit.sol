// SPDX-License-Identifier: MIT
pragma solidity ^0.4.24;

import "./IPozBenefit.sol";
import "./IStaking.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Benefit is IPOZBenefit, Ownable {
    constructor() public {
        MinHold = 1;
        ChecksCount = 0;
    }

    struct BalanceCheckData {
        bool IsToken; //token or staking contract address
        address ContractAddress; // the address of the token or the staking
        address LpContract; // check the current Token Holdin in Lp
    }

    uint256 public MinHold; //minimum total holding to be POOLZ Holder
    mapping(uint256 => BalanceCheckData) CheckList; //All the contracts to get the sum
    uint256 public ChecksCount; //Total Checks to make

    function SetMinHold(uint256 _MinHold) public onlyOwner {
        require(_MinHold > 0, "Must be more then 0");
        MinHold = _MinHold;
    }

    function AddNewLpCheck(address _Token, address _LpContract)
        public
        onlyOwner
    {
        CheckList[ChecksCount] = BalanceCheckData(false, _Token, _LpContract);
        ChecksCount++;
    }

    function AddNewToken(address _ContractAddress) public onlyOwner {
        CheckList[ChecksCount] = BalanceCheckData(
            true,
            _ContractAddress,
            address(0x0)
        );
        ChecksCount++;
    }

    function AddNewStaking(address _ContractAddress) public onlyOwner {//adds new staking to check
        CheckList[ChecksCount] = BalanceCheckData(
            false,
            _ContractAddress,
            address(0x0)
        );
        ChecksCount++;
    }

    function RemoveLastBalanceCheckData() public onlyOwner {
        require(ChecksCount > 0, "Can't remove from none");
        ChecksCount--;
    }

    function RemoveAll() public onlyOwner { //removes all checks
        ChecksCount = 0;
    }

    function CheckBalance(address _Token, address _Subject) //returns token balance of subject
        internal
        view
        returns (uint256)
    {
        return ERC20(_Token).balanceOf(_Subject);
    }

    function CheckStaking(address _Contract, address _Subject)//returns amount staked of subject
        internal
        view
        returns (uint256)
    {
        return IStaking(_Contract).stakeOf(_Subject);
    }

    function IsPOZHolder(address _Subject) external view returns (bool) {//does the subject hold enough to be consindered a holder?
        return CalcTotal(_Subject) >= MinHold;
    }

    function CalcTotal(address _Subject) public view returns (uint256) { //calculates total holdings of subject
        uint256 Total = 0;
        for (uint256 index = 0; index < ChecksCount; index++) { //runs over all checks
            if (CheckList[index].LpContract == address(0x0)) {//if check is not an lp check
                Total =
                    Total +
                    (
                        CheckList[index].IsToken //if check is token add balance of subject
                            ? CheckBalance(
                                CheckList[index].ContractAddress,
                                _Subject
                            ) //else add staking of subject
                            : CheckStaking(
                                CheckList[index].ContractAddress,
                                _Subject
                            )
                    );
            } else {//if check is an lp check
                Total =
                    Total +
                    _CalcLP( //add lp holdings to total
                        CheckList[index].LpContract,
                        CheckList[index].ContractAddress,
                        _Subject
                    );
            }
        }
        return Total;
    }

    function _CalcLP( // calculates lp holdings of subject
        address _Contract,
        address _Token,
        address _Subject
    ) internal view returns (uint256) {
        uint256 TotalLp = ERC20(_Contract).totalSupply(); // total lp supply
        uint256 SubjectLp = ERC20(_Contract).balanceOf(_Subject); // subject lp holdings
        uint256 TotalTokensOnLp = ERC20(_Token).balanceOf(_Contract); // total tokens the lp holds
        //SubjectLp * TotalTokensOnLp / TotalLp
        return SafeMath.div(SafeMath.mul(SubjectLp, TotalTokensOnLp), TotalLp);
    }
}
