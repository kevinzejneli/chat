//
pragma solidity ^0.8.7;

// import "github.com/OpenZeppelin/openzeppelin-solidity/contracts/utils/math/SafeMath.sol";

contract Chatroom {
    // using SafeMath for uint256;
    
    struct MessageStruct{
        address sender;  
        string content; 
        bool burned;     
    }

    address public creator;  
    address public recipient;

    constructor(address _creator, address _recipient){
        creator=_creator;
        recipient=_recipient;
    }
    
    mapping(address => MessageStruct[]) public messages;

    event NewMessage(string messageContent);
    event BurnedMessage(uint256 indexed msgIndex);

    function sendMessage(string memory _content) external {
        require(bytes(_content).length > 0, "Cannot send empty content.");

        // Check if user has already sent a message and it hasn't been burned
        for (uint i = messages[msg.sender].length -1; i >= 0; --i){
            MessageStruct memory msg = messages[msg.sender][i];
            
            require(msg.burned == false, "You still have an unburnt previous message.");
        
           // If the user has sent a message and it hasn't been burned
        }
       
       // Create new message struct with sender address set to current caller's address 
       MessageStruct memory msg = MessageStruct({
            sender:msg.sender,
            content:_content,  
            burned:false     
        });
            
         messages[msg.sender].push(msg);
        
      emit NewMessage(_content);

    }

    function burnCurrentMessage() external {
        // Check if the user has sent a message
        require(messages[msg.sender].length > 0,"You haven't sent any previous message.");
    
       MessageStruct memory msg =messages[msg.sender][messages[msg.sender].length-1];
       
      require(msg.burned == false, "The last message you've sent hasn't been burned yet.");

      // Update the 'burned' status of current user's messages
     for (uint i = 0; i < messages[msg.sender].length - 1 ; ++i) {
            MessageStruct storage msgStored =messages[ msg.sender][i];
            
           msgStored.burned=true;
        }
        
      // Update the last message, which is supposed to be burned 
       delete messages[msg.sender][messages[msg.sender].length-1];

    emit BurnedMessage(messages[msg.sender].length - 1);
    }
}

/**
 * ChatApp factory/registry contract.
 * Tracks all chatrooms between address pairs.
 */
contract ChatApp {
    mapping(bytes32 => address) public chatrooms;

    event ChatroomCreated(address indexed user1, address indexed user2, address chatroom);

    function _getKey(address a, address b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }

    function getOrCreateChatroom(address other) external returns (address) {
        require(other != msg.sender, "Cannot chat with self");
        bytes32 key = _getKey(msg.sender, other);

        if (chatrooms[key] == address(0)) {
            Chatroom room = new Chatroom(msg.sender, other);
            chatrooms[key] = address(room);
            emit ChatroomCreated(msg.sender, other, address(room));
        }

        return chatrooms[key];
    }
}
