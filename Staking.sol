// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    // we are gonna one token to be allowing to stake
    //that iz ERC20
    IERC20 public s_stakingToken;
 
     IERC20 public s_rewardsToken;

    //someones address that how much  they have staked
    mapping(address => uint) public s_balances;

    uint256 public s_totalSupply;

    // This is the reward token per second
    // Which will be multiplied by the tokens the user staked divided by the total
    // This ensures a steady reward rate of the platform
    // So the more users stake, the less for everyone who is staking.
    uint256 public constant REWARD_RATE = 100;
    uint256 public s_lastUpdateTime;
    uint256 public s_rewardPerTokenStored;

    event Staked(address indexed user, uint256 indexed amount);
    event WithdrewStake(address indexed user, uint256 indexed amount);
    event RewardsClaimed(address indexed user, uint256 indexed amount);

    modifier updatedReward(address account){
        s_rewardPerTokenStord=rewardPerToken();
    }

    constructor(address stakingToken, address rewardsToken) {
        s_stakingToken = IERC20(stakingToken);
        s_rewardsToken = IERC20(rewardsToken);
    }


    error Staking_TransferFailed();

    
    /**
     How much reward a token gets based on how long it's been in and during which "snapshots"
     */
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }

     /**
    How much reward a token gets based on how long it's been in and during which "snapshots"
     */
    function rewardPerToken() public view returns (uint256) {
        if (s_totalSupply == 0) {
            return s_rewardPerTokenStored;
        }
        return
            s_rewardPerTokenStored +
            (((block.timestamp - s_lastUpdateTime) * REWARD_RATE * 1e18) / s_totalSupply);
    }
    /**
       How much reward a user has earned
     */
    function earned(address account) public view returns (uint256) {
        return
            ((s_balances[account] * (rewardPerToken() - s_userRewardPerTokenPaid[account])) /
                1e18) + s_rewards[account];
    }

    function stake(uint256 amount) external {
        // keep track of ho wtoken this user has staked //
        // keep track of how much token we have total
        //transfer the tokens to this contract

        s_balances[msg.sender] = s_balances[msg.sender] + amount; // updating balance of this contract

        s_totalSupply = s_totalSupply + amount;

        bool success = s_stakingToken.transferFrom(
            msg.sender,
            address(this),
            amount
        );

        //require(succes,"failed"); // this would be gas expensive so

        //instead of using require use error-revert for gas optimization


        if (!success) {
            revert Staking_TransferFailed();  //cancel the transaction
        }


        //2. withdraw function

        function withdraw (uint256 amount) external{
            //update staking balance of user's
            s_balances[msg.sender]= s_balances[msg.sender]-amount;
            s_totalSupply-= amount;

            //we using trnafer function insteat of tranferfrom because this time we have balalnce in
            //contract  to tranfer to the withdrawer
           
            bool success =s_stakingToken.transfer(msg.sender,amount);
            // same as/
            // bool success =s_stakingToken.transfer(address(this),msg.sender,amount);
 if(!succes){
    revert Staking_TransferFailed();
 }
        }
    }


    //3. claimReward function
    function claimReward() external{
//how much reward do they get
//the contract is going to to emit X token per secnd;
// and disperse them to all token stakers

// amth for calculatin rewands
//if reward is 100 reward token/second   and there are two memebrs
// 1 tokens/staked toknes

// at time=0
 //person A:staked 80, earned:0, withdrawn:0
//  person B: staked:20,earned:0,withdrawn:0

// at time=1
 //person A:staked 80, earned:80, withdrawn:0
//  person B: staked:20,earned:20,withdrawn:0

// at time=2
 //person A:staked 80, earned:80+80=160, withdrawn:0
//  person B: staked:20,earned:20+20=40,withdrawn:0


// at time=3 
// new person enters
// stake 100
//total tokens staked in contract will be 200
//0.5 per staaked tokens

 //person A:staked 80, earned:160 +(80/200*100= 40) ==200, withdrawn:0
//  person B: staked:20,earned:40 + (20/200*100=10) ==50,withdrawn:0
 

uint256 reward = s_rewards[msg.sender];
s_rewards[msg.sender] = 0;
emit RewardsClaimed(msg.sender, reward);
bool success = s_rewardsToken.transfer(msg.sender, reward);
if (!success) {
    revert TransferFailed();
}
 
    }

    /********************/
    /* Modifiers Functions */
    /********************/
    modifier updateReward(address account) {
        s_rewardPerTokenStored = rewardPerToken();
        s_lastUpdateTime = block.timestamp;
        s_rewards[account] = earned(account);
        s_userRewardPerTokenPaid[account] = s_rewardPerTokenStored;
        _;
    }

    modifier moreThanZero(uint256 amount) {
        if (amount == 0) {
            revert NeedsMoreThanZero();
        }
        _;
    }


}
