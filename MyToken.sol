// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 1. Level Cơ bản nhất: Context
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}
// 2. Level Interface
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
// 3. Level Module Bảo mật: Ownable (Kế thừa Context)
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _owner = _msgSender();
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
}
// 4. Level Module Tiện ích: Pausable (Kế thừa Context)
abstract contract Pausable is Context {
    bool private _paused;
    event Paused(address account);
    event Unpaused(address account);

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}
// 5. Level Logic Chính: ERC20 (Kế thừa Context và IERC20)
contract ERC20 is Context, IERC20 {
    mapping(address => uint256) private _balances;
    uint256 private _totalSupply;

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] -= amount;
        _balances[recipient] += amount;
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
    }
}
// 6. CONTRACT CỦA BẠN (Tầng cao nhất - Đa kế thừa)
// Kế thừa từ cả ERC20, Ownable và Pausable
contract ComplexToken is ERC20, Ownable, Pausable {
    
    constructor(uint256 initialSupply) {
        _mint(msg.sender, initialSupply);
    }

    // Chức năng burn (đốt coin)
    function burn(uint256 amount) public onlyOwner {
        _mint(msg.sender, amount); // Giả lập logic
    }

    // Ghi đè hàm transfer để thêm tính năng Pause
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns (bool) {
        return super.transfer(recipient, amount);
    }
    
    function pause() public onlyOwner {
        _pause();
    }
    
    function unpause() public onlyOwner {
        _unpause();
    }
}