// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TheDeveloperGoblin {
    string public name = "TheDeveloperGoblin";
    string public symbol = "TDG";
    uint8 public decimals = 15;
    uint256 public totalSupply = 2000000 * (10 ** uint256(decimals));
    address public owner;
   
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
   
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   
    constructor() {
        owner = msg.sender;
        balances[owner] = totalSupply;
    }
   
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
   
    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }
   
    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balances[msg.sender], "ERC20: transfer amount exceeds balance");
       
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
       
        emit Transfer(msg.sender, recipient, amount);
       
        return true;
    }
   
    function approve(address spender, uint256 amount) public returns (bool) {
        allowances[msg.sender][spender] = amount;
       
        emit Approval(msg.sender, spender, amount);
       
        return true;
    }
   
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount <= balances[sender], "ERC20: transfer amount exceeds balance");
        require(amount <= allowances[sender][msg.sender], "ERC20: transfer amount exceeds allowance");
       
        balances[sender] -= amount;
        balances[recipient] += amount;
        allowances[sender][msg.sender] -= amount;
       
        emit Transfer(sender, recipient, amount);
       
        return true;
    }
   
    function allowance(address account, address spender) public view returns (uint256) {
        return allowances[account][spender];
    }
   
    function burn(uint256 amount) public returns (bool) {
        require(amount <= balances[msg.sender], "ERC20: burn amount exceeds balance");
       
        balances[msg.sender] -= amount;
        totalSupply -= amount;
       
        emit Transfer(msg.sender, address(0), amount);
       
        return true;
    }
   
    function mint(uint256 amount) public onlyOwner returns (bool) {
        require(totalSupply + amount <= 2**256 - 1, "ERC20: total supply exceeds uint256");
       
        balances[owner] += amount;
        totalSupply += amount;
       
        emit Transfer(address(0), owner, amount);
       
        return true;
    }

    bool public paused = false;
    mapping(address => bool) public frozenAccounts;

    // Modifier to check if transfers are allowed
    modifier whenNotPaused() {
        require(!paused, "Transfers are paused");
        _;
    }

    modifier whenNotFrozen(address _account) {
        require(!frozenAccounts[_account], "Account is frozen");
        _;
    }

    // Function to pause transfers
    function pause() public onlyOwner {
        paused = true;
    }

    // Function to unpause transfers
    function unpause() public onlyOwner {
        paused = false;
    }

    // Function to freeze an account
    function freezeAccount(address _account) public onlyOwner {
        frozenAccounts[_account] = true;
    }

    // Function to unfreeze an account
    function unfreezeAccount(address _account) public onlyOwner {
        frozenAccounts[_account] = false;
    }

    // Function for batch transfer
    function batchTransfer(address[] memory _recipients, uint256[] memory _amounts) public whenNotPaused returns (bool) {
        require(_recipients.length == _amounts.length, "Array lengths must match");

        uint256 totalAmount = 0;
        for (uint256 i = 0; i < _recipients.length; i++) {
            address recipient = _recipients[i];
            uint256 amount = _amounts[i];
            require(recipient != address(0), "Invalid recipient address");
            require(amount <= balances[msg.sender], "Transfer amount exceeds balance");
            totalAmount += amount;

            balances[msg.sender] -= amount;
            balances[recipient] += amount;
            emit Transfer(msg.sender, recipient, amount);
        }
        require(totalAmount > 0, "No tokens to transfer");
        return true;
    }

    // Function to update token name and symbol
    function updateTokenMetadata(string memory _newName, string memory _newSymbol) public onlyOwner {
        name = _newName;
        symbol = _newSymbol;
    }
}
