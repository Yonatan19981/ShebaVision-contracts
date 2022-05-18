// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SHEBA {
    string public name = "SHEBA";
    uint256 public fileCount = 0;
    uint public userIds = 1;
    address public admin;
    mapping(uint256 => File) public files;
    mapping(address => Identity) public identities;

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
    }

    constructor(){
        admin=msg.sender;
        identities[admin].userId=userIds;
        userIds++;
        identities[admin].userName = "Yonatan Martsiano";
        identities[admin].reviewer=true;
        identities[admin].publisher=true;
        identities[admin].author=true;

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
      if (keccak256(abi.encodePacked(_paperType)) == keccak256(abi.encodePacked("Manuscript"))) {
  require(identities[msg.sender].author,"only authors can upload manuscripts");
}
if (keccak256(abi.encodePacked(_paperType)) == keccak256(abi.encodePacked("Review"))) {
  require(identities[msg.sender].reviewer,"only reviewers can upload reviews");
}
if (keccak256(abi.encodePacked(_paperType)) == keccak256(abi.encodePacked("Update"))) {
  require(identities[msg.sender].reviewer,"only reviewers can upload updates");
}
        fileCount++;

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
        
    }

function isAuthor(address _author) public view returns(bool) {
        return identities[_author].author;
    }
function isPublisher(address _publisher) public view returns(bool) {
        return identities[_publisher].publisher;
    }
function isReviewer(address _reviewer) public view returns(bool) {
        return identities[_reviewer].reviewer;
    }
function newUser(address wallet,string memory _name) public {
    require(msg.sender==admin,"only admin can add users");
        identities[wallet].userId=userIds;
        userIds++;
        identities[wallet].userName=_name;
}
    function setAuthor(address _author) public {
        require(msg.sender==admin,"only admin can set author");
        identities[_author].author=true;
    }

    function setReviewer(address _reviewer) public {
        require(msg.sender==admin,"only admin can set author");
        identities[_reviewer].reviewer=true;
    }
    function setPublisher(address _publisher) public {
        require(msg.sender==admin,"only admin can set author");
        identities[_publisher].publisher=true;
    }

    function cancelAuthor(address _author) public {
        require(msg.sender==admin,"only admin can set author");
        identities[_author].author=false;
    }

    function cancelReviewer(address _reviewer) public {
        require(msg.sender==admin,"only admin can set author");
        identities[_reviewer].reviewer=false;
    }
    function cancelPublisher(address _publisher) public {
        require(msg.sender==admin,"only admin can set author");
        identities[_publisher].publisher=false;
    }
}
