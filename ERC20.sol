// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.5;
contract ERC20 is IERC20 {
    uint256 public totalSupply;
    mapping(address => uint256) balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    string public name = "Singular Coin";
    string public symbol = "SING";
    uint256 public decimal = 18;

    // when we transfer the mooney from ofunction caller to function getter our amount would be deducted
    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        balanceOf[msg.sender] -= amount; // amount would be deducted from sender's account
        balanceOf[recipient] += amount; // amount would be credited in recipien's account

        // and we will say that this amount has been sent from this account to that account  by simply emitting the trnasefer function
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    //approver-->spender -->amount
    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount; // means function approver gave the allowance to spender to spent that much amount to carry with him
        emit Approval(msg.spender, spender, amount);
        return true;
    }

    // transfer money from sender's(allowed balance) to recipient
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(balanceOf(sender) >= 0, "not enought money");
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        return true;
    }

    // function to increase tokenSupply
    function mint(uint256 amount) external {
        balanceOf(msg.sender) += amount;
        totalSupply += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    // function to reduce totalSupply
    function burn(uint256 amount) external {
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
        emit Transfer(msg.sender, address(0), amount);
    }
}
