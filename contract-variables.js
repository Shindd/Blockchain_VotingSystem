// We use the struct datatype to store the voter information.
  struct voter {
    address voterAddress; // The address of the voter
    uint tokensBought;    // The total no. of tokens this voter owns
    uint[] tokensUsedPerCandidate; // Array to keep track of votes per candidate.
    /* We have an array called candidateList initialized below.
     Every time this voter votes with her tokens, the value at that
     index is incremented. Example, if candidateList array declared
     below has ["Rama", "Nick", "Jose"] and this
     voter votes 10 tokens to Nick, the tokensUsedPerCandidate[1] 
     will be incremented by 10.
     */
  }
/* mapping is equivalent to an associate array or hash.
 The key of the mapping is candidate name stored as type bytes32 
 and value is an unsigned integer which used to store the vote 
 count
 */
mapping (bytes32 => uint) public votesReceived;
mapping (address => voter) public voterInfo;
/* Solidity doesn't let you return an array of strings yet. We will 
 use an array of bytes32 instead to store the list of candidates
 */
bytes32[] public candidateList;
uint public totalTokens; // Total no. of tokens available for this election
uint public balanceTokens; // Total no. of tokens still available for purchase
uint public tokenPrice; // Price per token
