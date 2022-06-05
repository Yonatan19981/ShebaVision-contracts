// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SHEBASTUDY {
    // status : 0 open for review,1 under review,2 approved,3 need revision
    string public name = "SHEBASTUDY";
    uint256 public fileCount = 1;
    uint public userIds = 1;
    address public admin;
    mapping(uint256 => File) public files;
    mapping(uint256 => address) public userById;
    mapping(address => Identity) public identities;
    //each file number has several reviewers assigned
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
        uint256 status;
        address publisher;
        uint256 updateNumber;
    }

   struct Identity {
        uint256 userId;
        string userName;
        bool reviewer;
        bool publisher;
        bool author;
        bool admin;
        //the publisher employing this person if he is a reviewer 
        address employer;
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
bool _needrevision=keccak256(abi.encodePacked(_paperType)) == keccak256(abi.encodePacked("NeedRevision"));
require(_manuscript||_review||_update||_needrevision,"File has to be of correct paper type");
uint _status;
address _publisher;
uint _updatedNumber=0;

      if (_manuscript) {
  require(identities[msg.sender].author,"only authors can upload manuscripts");
  _status=0;
  _publisher=address(0);
}
if (_review) {
  require(identities[msg.sender].reviewer,"only reviewers can upload reviews");
  require(files[_connectedTo].publisher==identities[msg.sender].employer,"Reviewer is not working for this publisher");
    _status=1;
    _publisher=address(0);

}
if (_update) {  
  require(identities[msg.sender].author,"only authors can upload updates");
  fileCount=_connectedTo;
    _publisher=files[_connectedTo].publisher;
    _updatedNumber=files[_connectedTo].updateNumber+1;
    _subject=files[_connectedTo].subject;
    _paperType=files[_connectedTo].paperType;
    _connectedTo=files[_connectedTo].connectedTo;

}
 if (_needrevision) {
require(identities[msg.sender].publisher,"only publishers upload revision requests");
require(files[_connectedTo].publisher==msg.sender,"only relevent publisher can upload revision requests");
  _status=3;
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
            payable(msg.sender),
            _status,
            _publisher,
            _updatedNumber
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
        identities[wallet].employer=address(0);
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

        function returnFile(uint _file) public{
        require(identities[msg.sender].publisher,"only publishers can return files");
        require(files[_file].publisher==msg.sender,"only relevent publisher can return files");
        files[fileCount].status=0;
        files[_file].publisher=address(0);
    }

     function employReviewer(address _reviewer) public{
        require(identities[msg.sender].publisher,"only publishers can return files");
        require(identities[_reviewer].employer==address(0),"only unemployed reviewers can be employed");
        identities[_reviewer].employer=msg.sender;
    }

      function reviewerUnmploy() public{
        require(identities[msg.sender].reviewer,"only reviewers can unmploy themselves");
       identities[msg.sender].employer=address(0);
    }


     function ApprovePublished(uint _file) public{
        require(identities[msg.sender].author,"only authors can approve reviews");
        require(files[_file].uploader==msg.sender,"only file author can confirm a file has been published");
        bool _manuscript=keccak256(abi.encodePacked(files[_file].paperType)) == keccak256(abi.encodePacked("Manucsript"));
        require(_manuscript,"only a manuscript can be approved");
        files[fileCount].status=2;
    }
        function ApproveReview(uint _file) public{
        require(identities[msg.sender].publisher,"only publishers can approve reviews");
        require(identities[files[_file].uploader].employer==msg.sender,"only publisher employing reviewer can approve a review");
        bool _review=keccak256(abi.encodePacked(files[_file].paperType)) == keccak256(abi.encodePacked("Review"));
        require(_review,"only a review can be approved");
        files[fileCount].status=2;
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

    function getStatus(uint256 Id) public view returns(uint){
          return files[Id].status;

    }
    
        function isPublisherForFile(uint _file,address _publisher) public view returns (bool){
        if(files[_file].publisher==_publisher){
            return true;
        }
        return false;
    }
}
