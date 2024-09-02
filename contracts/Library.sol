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
        uint256[] booksborrowed;
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

    mapping(address => User) public  users;
    mapping (uint256 => Book) public books;

    constructor(string memory _name) {
        User memory user = User({
        userId:msg.sender,
        name:_name,
        booksborrowed: new uint256[](10),
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
        booksborrowed: new uint256[](0),
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

    function borrowBook(uint256 _bookId) public  returns (Book memory){
        Book storage book = books[_bookId];
        User storage user = users[msg.sender];
        bool isAvail;

        for (uint256 i = 0; i < user.booksborrowed.length; i++) {
            if (user.booksborrowed[i] == _bookId) {
                isAvail = true;
            }
            isAvail = false;
        }
        require(book.quantity >= 1, "This book is currently not available, check back later :)");
        require(isAvail == false, "You already have this book :)");

        user.booksborrowed.push(book.bookId);
        book.quantity --;
        return book;
    }

    function makeAuthor(address _user) public onlyAdmin  returns(User memory){
        
        User storage user = users[_user];

        user.userRole = role.AUTHOR;

        return user;
    }
}