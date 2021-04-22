// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.7.6;

interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

contract EarthTokenReward {
    using SafeMath for uint256;

    address public owner;
    uint256 public duration = 30 days;
    uint256 public periodFinish = 0;

    uint256 public totalSupply;
    mapping(address => uint256) public balances;
    IERC20 token=IERC20(0xfF7DAB289C9F49d348B93f21725BB5903D02C8d6);
    IERC20 public rewardToken;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    constructor() {
        owner = msg.sender;
    }

    function sendToken() public {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        token.transferFrom(msg.sender, address(this), token.balanceOf(msg.sender));
    }

    function stake(uint256 _amount) public {
        token.transferFrom(msg.sender, address(this), _amount);
        totalSupply = totalSupply.add(_amount);
        balances[msg.sender] = balances[msg.sender].add(_amount);
    }

    function withdraw(uint256 _amount) public {
        totalSupply = totalSupply.sub(_amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        token.transfer(msg.sender, _amount);
    }

    function recoverEarth(address _token, uint256 _amount) external {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        require(_token != address(0), "StakingErc20: _token is zero address");
        require(_token != address(token), "StakingErc20: _token and lpToken addresses are the same");

        token.transfer(msg.sender, _amount);
        // emit Recovered(_token, _amount);
    }

    // function earned(address _account) public view returns (uint256) {
    //     return balanceOf(_account)
    //     .mul(rewardPerToken().sub(userRewardPerTokenPaid[_account]))
    //     .div(1e18)
    //     .add(rewards[_account]);
    // }

    function getReward() external {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[(msg.sender)] = 0;
            rewardToken.transfer(msg.sender, reward);

            // emit RewardPaid((msg.sender, reward);
        }
    }

}
