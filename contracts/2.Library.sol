// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.1;

contract Library{

     enum role {
       USER,
       AUTHOR,
       ADMIN
    }
 
    struct User{
        address userId;
        string name;
        role userRole;
    }
    struct Book{
        uint256 bookId;
        string name;
        address authorId;
        string image;
        string description;
        uint256 publication_year;
        uint256 quantity;
    }
    struct Bd{
        uint256[] booksborrowed;
    }

    mapping(address => User) public  users;
    mapping(address => Bd) private borrows;
    mapping (uint256 => Book) public books;

    constructor(string memory _name) {
        User memory user  = User({
        userId:msg.sender,
        name:_name,
        userRole: role.ADMIN
       }); 

       users[msg.sender]=user;
    }

    uint256 public numberofbooks = 0;

    modifier onlyAdmin() {
        User memory admin = users[msg.sender];
        require(admin.userRole == role.ADMIN,"This is an admin call");
        _;
    }
    modifier onlyAuthor() {
        require(isAuthor(msg.sender), "Unauthorized user");
        _;
    }
    modifier onlyUser() {
        require(users[msg.sender].userRole == role.USER, "You dont need this");
        _;
    }

    event callToAdmin(address sender, string value);
 
    function isAuthor(address _userId) public view returns(bool){
        User storage user = users[_userId];
        return user.userRole == role.AUTHOR || user.userRole == role.ADMIN;
    }
    
    function createUser(string memory _name) public returns (User memory){
       
       User storage currentUser = users[msg.sender];
       require(currentUser.userId == address(0x00000), "user already exist");

       User memory user = User({
        userId:msg.sender,
        name:_name,
        userRole: role(0)
       }); 

       users[msg.sender]=user;
       return user;
    }


    function createBook(
        string memory _name,
        string memory _image,
        string memory _description,
        uint256 _publication_year,
        uint256 _quantity
        ) public  onlyAuthor returns (uint256){

     

        Book memory book = Book({
            bookId:numberofbooks,
            name:_name,
            authorId:msg.sender,
            image:_image,
            description:_description,
            publication_year:_publication_year,
            quantity:_quantity
        });
        books[numberofbooks] = book;
        numberofbooks ++;
        return numberofbooks;
    }

    function askToBeAuthor() public onlyUser{
        emit callToAdmin(msg.sender, "hello admin, im need your response");
    }


    function borrowBook(uint256 _bookId) public{
        require(users[msg.sender].userId == msg.sender, "User not registered");

        Book storage book = books[_bookId];
        Bd storage bd = borrows[msg.sender];
    
        require(book.quantity > 0, "This book is currently not available, check back later :)");
    
        bool isAlreadyBorrowed = false;

        for (uint256 i = 0; i < bd.booksborrowed.length; i++) {
            if (bd.booksborrowed[i] == _bookId) {
                isAlreadyBorrowed = true;
                break;
            }
        }

        require(!isAlreadyBorrowed, "You already have this book :)");

        bd.booksborrowed.push(_bookId);
        book.quantity--;
    }
    function getBorrowedBooks(address _user) public view returns (uint256[] memory) {
        return borrows[_user].booksborrowed;
    }


    function makeAuthor(address _user) public onlyAdmin  returns(User memory){
        
        User storage user = users[_user];

        user.userRole = role.AUTHOR;

        return user;
    }

    function returnBook(uint256 bookId) public {
        require(users[msg.sender].userId == msg.sender, "User not registered");

        Bd storage bd = borrows[msg.sender];
        uint256 index = findBookIndex(bd.booksborrowed, bookId);
        if (index != bd.booksborrowed.length) {
            bd.booksborrowed[index] = bd.booksborrowed[bd.booksborrowed.length - 1];
            bd.booksborrowed.pop();
        }
    }

    function findBookIndex(uint256[] memory arr, uint256 value) internal pure returns (uint256) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == value) {
                return i;
            }
        }
        return arr.length;
    }
}