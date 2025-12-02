// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; // 1. FIX: Cập nhật lên phiên bản ổn định, mới hơn (0.8.20)

contract SecureVault {
    // Thêm modifier chống Tái nhập (Reentrancy Guard)
    bool internal locked;
    modifier nonReentrant() {
        require(!locked, "ReentrancyGuard: Reentrant call");
        locked = true;
        _;
        locked = false;
    }

    mapping(address => uint) public balances;
    // 2. FIX: Khai báo owner là immutable để tiết kiệm gas và đảm bảo tính bất biến
    address immutable public owner; 

    constructor() {
        owner = msg.sender;
    }

    // 3. FIX: Thêm modifier an toàn (safe modifier) cho deposit
    function deposit() public payable {
        // FIX: Không sử dụng tx.origin. Luôn sử dụng msg.sender
        balances[msg.sender] += msg.value; 
    }

    // 4. FIX: Áp dụng Checks-Effects-Interactions và nonReentrant
    function withdraw(uint amount) public nonReentrant {
        // CHECK 1: Đảm bảo số tiền rút không vượt quá số dư
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // EFFECTS: Cập nhật trạng thái trước khi tương tác ngoài (chống Reentrancy)
        balances[msg.sender] -= amount;

        // INTERACTION: Thực hiện lệnh gọi cấp thấp
        // FIX: Kiểm tra giá trị trả về của call
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed"); // FIX: Khôi phục giao dịch nếu chuyển tiền thất bại
    }

    // 5. FIX: Thay thế hàm suicide() bằng hàm withdrawAll() an toàn hơn và loại bỏ selfdestruct
    function withdrawAll() public {
        require(msg.sender == owner, "Only owner can call this function");
        // Chuyển toàn bộ Ether về owner
        (bool success, ) = payable(owner).call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}