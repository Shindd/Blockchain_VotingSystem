pragma solidity ^0.4.11;

/// @title Voting with delegation.
contract BallotMaster{
    mapping(address => Ballot) private ballots;
    address[] private addressList;
    
    function addBallot(bytes32 name)
    {
        Ballot ballot = new Ballot(name);
        addressList.push(address(ballot));
        ballots[address(ballot)] = ballot;
    }
    function getBallotAddressList() constant returns
    (address[] ballotAddressList){
        ballotAddressList = addressList;
    }
}

contract Ballot {
    // This declares a new complex type which will
    //be used for variables later.
    // It will represent a single voter.
    bytes32 BallotName;
    struct Voter {
        uint weight; // weight is accumulated by delegation
        bool voted;  // if true, that person already voted
        address delegate; // person delegated to
        uint vote;   // index of the voted proposal
    }

    // This is a type for a single proposal.
    struct Proposal {
        bytes32 name;   // short name (up to 32 bytes)
        uint voteCount; // number of accumulated votes
    }

    address public chairperson;

    // This declares a state variable that
    // stores a `Voter` struct for each possible address.
    mapping(address => Voter) public voters;
    
    // A dynamically-sized array of `Proposal` structs.
    Proposal[] public proposals;

    /// Create a new ballot to choose one of `proposalNames`.
    function Ballot(bytes32 Ballotname) {
        BallotName = Ballotname;
        chairperson = msg.sender;
        voters[chairperson].weight = 1;
    }
   
    function addProposal(bytes32 Name){
        proposals.push(Proposal({
                name: Name,
                voteCount: 0
        }));
    }
    // Give `voter` the right to vote on this ballot.
    // May only be called by `chairperson`.
    function giveRightToVote(address voter) {
        // If the argument of `require` evaluates to `false`,
        // it terminates and reverts all changes to
        // the state and to Ether balances. It is often
        // a good idea to use this if functions are
        // called incorrectly. But watch out, this
        // will currently also consume all provided gas
        // (this is planned to change in the future).
        require((msg.sender == chairperson) && !voters[voter].voted && (voters[voter].weight == 0));
        voters[voter].weight = 1;
    }

    /// Delegate your vote to the voter `to`.
    function delegate(address to) {
        // assigns reference
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);

        // Self-delegation is not allowed.
        require(to != msg.sender);

        // Forward the delegation as long as
        // `to` also delegated.
        // In general, such loops are very dangerous,
        // because if they run too long, they might
        // need more gas than is available in a block.
        // In this case, the delegation will not be executed,
        // but in other situations, such loops might
        // cause a contract to get "stuck" completely.
        while (voters[to].delegate != address(0)) {
            to = voters[to].delegate;

            // We founxd a loop in the delegation, not allowed.
            require(to != msg.sender);
        }

        // Since `sender` is a reference, this
        // modifies `voters[msg.sender].voted`
        sender.voted = true;
        sender.delegate = to;
        Voter delegate = voters[to];
        if (delegate.voted) {
            // If the delegate already voted,
            // directly add to the number of votes
            proposals[delegate.vote].voteCount += sender.weight;
        } else {
            // If the delegate did not vote yet,
            // add to her weight.
            delegate.weight += sender.weight;
        }
    }

    /// Give your vote (including votes delegated to you)
    /// to proposal `proposals[proposal].name`.
    function vote(uint proposal) {
        Voter storage sender = voters[msg.sender];
        require(!sender.voted);
        sender.voted = true;
        sender.vote = proposal;

        // If `proposal` is out of the range of the array,
        // this will throw automatically and revert all
        // changes.
        proposals[proposal].voteCount += sender.weight;
    }
    /*
    function getProposalAddressList() constant returns
    (address[] proposalAddressList){
        proposalAddressList = proposals;
    }
    */
    /// @dev Computes the winning proposal taking all
    /// previous votes into account.
    function getProposal() constant returns(Proposal[] proprsals)
    {
        
    }
    function winningProposal() constant
            returns (uint winningProposal)
    {
        uint winningVoteCount = 0;
        for (uint p = 0; p < proposals.length; p++) {
            if (proposals[p].voteCount > winningVoteCount) {
                winningVoteCount = proposals[p].voteCount;
                winningProposal = p;
            }
        }
    }
    
    // Calls winningProposal() function to get the index
    // of the winner contained in the proposals array and then
    // returns the name of the winner
    function winnerName() constant
            returns (bytes32 winnerName)
    {
        winnerName = proposals[winningProposal()].name;
    }
}
