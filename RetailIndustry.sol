// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Retail {
    address payable owner;
    struct Product {
        bytes32 name;
        uint price;
        uint mfd;
        uint stock;
    }

    mapping(bytes32 => Product) public products;

    // Event to emit when a product is added
    event NewProduct(bytes32 name, uint price);

    constructor() {
        owner == payable(msg.sender);
    }

    //add product
    function addProduct(
        bytes32 _name,
        uint _price,
        uint _mfd,
        uint _quantity
    ) external {
        require(msg.sender == owner, "only owener can add the new products");

        products[_name] = Product(_name, _price, _mfd, _quantity);
        emit NewProduct(_name, _price);
    }

    function updateProductDetails(
        bytes32 name,
        uint newPrice,
        uint newQuantity
    ) external {
        require(msg.sender == owner, "only owener can update the products");
        require(products[name].price > 0, "price must be greator than 0");
        require(products[name].stock > 0, "quantity can not be 0");

        products[name].price = newPrice;
        products[name].stock = newQuantity;
    }

    function purchaseProduct(bytes32 _name, uint _quantity) public payable {
        require(
            msg.value == products[_name].price * _quantity,
            "insufficient money"
        );
        require(
            _quantity <= products[_name].stock,
            "insuffient product quantity"
        );

        payable(msg.sender).transfer(msg.value);
        products[_name].stock -= _quantity;
    }

    function getProduct(
        bytes32 _productName
    ) external view returns (bytes32, uint, uint) {
        return (
            products[_productName].name,
            products[_productName].price,
            products[_productName].stock
        );
    }
}
