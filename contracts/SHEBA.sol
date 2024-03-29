// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SHEBA {
    enum Status{OpenForReview, UnderReview, ReviewPublished,Published }

    string public name = "SHEBA";
    uint256 public fileCount = 1;
    uint public userIds = 1;
    address public admin;
    mapping(uint256 => File) public files;
    mapping(uint256 => address) public userById;
    mapping(address => Identity) public identities;
    mapping (uint256=>Status) fileStatus;
    //each file number has several reviewers assigned
    mapping (uint256=>address) ReviewerAssigned;
    mapping (uint256=>address) PublisherChosen;
    mapping(string=>bool) named;
    struct File {
        uint256 fileId;
        string filePath;
        uint256 fileSize;
        string fileType;
        string fileName;
        string subject;
        string paperType;
        uint256 connectedTo;
        address payable uploader;
    }

   struct Identity {
        uint256 userId;
        string userName;
        bool reviewer;
        bool publisher;
        bool author;
        bool admin;
    }

    constructor(){
        identities[msg.sender].admin=true;
        identities[msg.sender].userId=userIds;
        userById[identities[msg.sender].userId]=msg.sender;
        userIds++;
        
        identities[msg.sender].userName = "Yonatan Martsiano";
        identities[msg.sender].reviewer=true;
        identities[msg.sender].publisher=true;
        identities[msg.sender].author=true;

    }
     function uploadFile(
        string memory _filePath,
        uint256 _fileSize,
        string memory _fileType,
        string memory _fileName,
        string memory _subject,
        string memory _paperType,
        uint256 _connectedTo
    ) public {
        require(bytes(_filePath).length > 0);
        require(bytes(_fileType).length > 0);
        require(bytes(_fileName).length > 0);
        require(bytes(_subject).length > 0);
        require(msg.sender != address(0));
        require(_fileSize > 0);
bool _manuscript=keccak256(abi.encodePacked(_paperType)) == keccak256(abi.encodePacked("Manuscript"));
bool _review=keccak256(abi.encodePacked(_paperType)) == keccak256(abi.encodePacked("Review"));
bool _update=keccak256(abi.encodePacked(_paperType)) == keccak256(abi.encodePacked("Update"));
require(_manuscript||_review||_update,"File has to be of correct paper type");
      if (_manuscript) {
  require(identities[msg.sender].author,"only authors can upload manuscripts");
  fileStatus[fileCount]=Status.OpenForReview;
  PublisherChosen[fileCount]=address(0);
}
if (_review) {
  require(identities[msg.sender].reviewer,"only reviewers can upload reviews");
  require(ReviewerAssigned[_connectedTo]==msg.sender,"Reviewer is not assigned for this file");
    fileStatus[fileCount]=Status.ReviewPublished;

}
if (_update) {
  require(identities[msg.sender].author,"only authors can upload updates");
}


        files[fileCount] = File(
            fileCount,
            _filePath,
            _fileSize,
            _fileType,
            _fileName,
            _subject,
            _paperType,
            _connectedTo,
            payable(msg.sender)
        );
        
                fileCount++;
    }

function newUser(address wallet,string memory _name) public {
    require(identities[msg.sender].admin,"only admin can add users");
    require(!named[_name],"user name already in system");
        identities[wallet].userId=userIds;
        userById[identities[wallet].userId]=wallet;
        userIds++;
        identities[wallet].userName=_name;
        named[_name]=true;
}
function getName(address _user) public view returns (string memory _name){
    require(identities[_user].userId!=0,"No such user in the system");
    _name=identities[_user].userName;
}
function isUser(address _user) public view returns (bool){
    if(identities[_user].userId==0){
        return false;
    }else{
        return true;
    }
}

    function assignReviewer(uint _file,address _reviewer) public{
        require(identities[msg.sender].publisher,"only publishers can assign reviewers");
        require(identities[_reviewer].reviewer,"can only assign reviewers");
        require(PublisherChosen[_file]==address(0),"another publisher has already chosen this file");
        ReviewerAssigned[_file]=_reviewer;
        fileStatus[_file]=Status.UnderReview;
        PublisherChosen[_file]=msg.sender;
    }

        function returnFile(uint _file) public{
        require(identities[msg.sender].publisher,"only publishers can return files");
        ReviewerAssigned[_file]=address(0);
        fileStatus[_file]=Status.OpenForReview;
        PublisherChosen[_file]=address(0);
    }

     function confirmPublished(uint _file) public{
        require(identities[msg.sender].author,"only authors can confirm files has been published");
        require(files[_file].uploader==msg.sender,"only file author can confirm a file has been published");
        bool _manuscript=keccak256(abi.encodePacked(files[_file].paperType)) == keccak256(abi.encodePacked("Manuscript"));
        require(_manuscript,"only a manuscript can be published");
        fileStatus[_file]=Status.Published;
        
    }
  function setAuthor(address _user) public {
        require(identities[msg.sender].admin,"only admin can set author");
         require(identities[_user].userId!=0,"No such user in the system");
        identities[_user].author=true;
    }

    function setReviewer(address _user) public {
        require(identities[msg.sender].admin,"only admin can set author");
         require(identities[_user].userId!=0,"No such user in the system");
        identities[_user].reviewer=true;
    }
    function setPublisher(address _user) public {
        require(identities[msg.sender].admin,"only admin can set author");
        require(identities[_user].userId!=0,"No such user in the system");
        identities[_user].publisher=true;
    }

    function cancelAuthor(address _user) public {
        require(identities[msg.sender].admin,"only admin can set author");
        require(identities[_user].userId!=0,"No such user in the system");
        identities[_user].author=false;
    }

    function cancelReviewer(address _user) public {
        require(identities[msg.sender].admin,"only admin can set author");
        require(identities[_user].userId!=0,"No such user in the system");
        identities[_user].reviewer=false;
    }
    function cancelPublisher(address _user) public {
        require(msg.sender==admin,"only admin can set author");
        require(identities[_user].userId!=0,"No such user in the system");
        identities[_user].publisher=false;
    }

function isAuthor(address _user) public view returns(bool) {
        return identities[_user].author;
    }
function isPublisher(address _user) public view returns(bool) {
        return identities[_user].publisher;
    }
function isReviewer(address _user) public view returns(bool) {
        return identities[_user].reviewer;
    }

    function getStatus(uint256 Id) public view returns(Status){
          return fileStatus[Id];

    }
    
    function isReviewing(uint _file,address _reviewer) public view returns (bool){
        if(ReviewerAssigned[_file]==_reviewer){
            return true;
        }
        return false;
    }
        function isPublisherChosen(uint _file,address _publisher) public view returns (bool){
        if(PublisherChosen[_file]==_publisher){
            return true;
        }
        return false;
    }
}
