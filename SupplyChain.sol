// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SupplyChain {
    address public owner;

    struct User {
        address userAddress;
        string name;
        string role;
        bool isActive;
    }

    struct Product {
        uint id;
        string name;
        uint price;
        uint stock;
    }

    struct Order {
        uint id;
        address customer;
        uint productId;
        uint quantity;
        uint totalAmount;
        bool isShipped;
    }

    mapping(address => User) public users;
    mapping(uint => Product) public products;
    mapping(uint => Order) public orders;
    mapping(address => mapping(uint => bool)) public userOrders;

    uint public productCount;
    uint public orderCount;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addUser(
        address _userAddress,
        string memory _name,
        string memory _role
    ) public onlyOwner {
        User memory user = User(_userAddress, _name, _role, true);
        users[_userAddress] = user;
    }

    function addProduct(
        string memory _name,
        uint _price,
        uint _stock
    ) public onlyOwner {
        productCount++;
        Product memory product = Product(productCount, _name, _price, _stock);
        products[productCount] = product;
    }

    function placeOrder(uint _productId, uint _quantity) public {
        require(users[msg.sender].isActive == true, "User is inactive");
        require(products[_productId].stock >= _quantity, "Insufficient stock");

        orderCount++;
        uint256 totalAmount = products[_productId].price * _quantity;
        Order memory order = Order(
            orderCount,
            msg.sender,
            _productId,
            _quantity,
            totalAmount,
            false
        );
        orders[orderCount] = order;
        products[_productId].stock -= _quantity;
        userOrders[msg.sender][orderCount] = true;
    }

    function shipOrder(uint _orderId) public onlyOwner {
        require(orders[_orderId].isShipped == false, "Order already shipped");
        orders[_orderId].isShipped = true;
    }

    function viewProduct(
        uint _productId
    ) public view returns (string memory, uint, uint) {
        return (
            products[_productId].name,
            products[_productId].price,
            products[_productId].stock
        );
    }

    function viewOrder(
        uint _orderId
    ) public view returns (address, uint, uint, uint, bool) {
        return (
            orders[_orderId].customer,
            orders[_orderId].productId,
            orders[_orderId].quantity,
            orders[_orderId].totalAmount,
            orders[_orderId].isShipped
        );
    }

    function viewUserOrders() public view returns (uint[] memory) {
        uint[] memory userOrderIds = new uint[](orderCount);
        uint counter = 0;
        for (uint i = 1; i <= orderCount; i++) {
            if (userOrders[msg.sender][i] == true) {
                userOrderIds[counter] = i;
                counter++;
            }
        }
        uint[] memory userOrdersTrimmed = new uint[](counter);
        for (uint i = 0; i < counter; i++) {
            userOrdersTrimmed[i] = userOrderIds[i];
        }
        return userOrdersTrimmed;
    }
}
