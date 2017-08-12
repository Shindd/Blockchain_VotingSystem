
/// @title 투표 및 위임
contract Ballot{


bytes32[10] bytesArray;
 // 이 선언은 새로운 타잎으로 나중에 쓰인다
 // 한 명의 투표자를 나타낸다
 struct Voter{
     uint weight; // weight은 다른 사람이 위임함에 따라 커진다
     bool voted; // 만약 true라면 이 사람은 이미 투표한 것이다
     address delegate; // 자신의 투표권일 위임한 사람의 주소
     uint vote; // 투표한 제안의 인덱스 값
 }

 // 이 것은 하나의 안건을 나타낸다.
 struct Proposal{
     bytes32 name; // 짧은 이름(32바이트 까지)
     uint voteCount; // 총 누적 득표 수
 }

 address public chairperson;

 // 이것은 가능한 주소들이 ‘Voter’ 구조체를 저장할 수 있는 상태 변수를 선언한다.
 mapping(address => Voter) public voters;

 // 동적으로 크기가 조정되는 “Proposal”구조체 선언
 Proposal [] public proposals;

 // ‘ProposalNames’중 하나를 선택하는 투표를 만든다.
 function Ballot( bytes32[ ] proposalNames ){
     chairperson = msg.sender;
     voters[chairperson].weight = 1;

     //각각의 제공된 proposalNames들은 새로운 안건 객체를 만들고 이것을 배열 끝에 추가한다.
     for ( uint i = 0 ; i < proposalNames.length; i++ ){

         // ‘proposal({ ... })’ 은 일시적인 안건 객체를 생성하고
         // ‘proposal.push( ... )’ 는 안건 객체를 proposal 배열 끝에 추가한다.
         proposals.push(Proposal( {
             name : proposalNames[i],
             voteCount : 0
         }));
     }
 }

 /// ‘voter’에게 이 투표에 대한 권한을 부여한다.
 /// 오직 chairperson에 의해서만 호출될 수 있다.
 function giveRightToVote(address voter){
     if( msg.sender != chairperson || voters[voter].voted ){

         // ‘throw’는 모든 상태 변화와 이더리움 잔액 변동을
         // 원래의 값으로 되돌린다. 만약 함수가 잘못된 방식으로 호출될 경우
         // 이러한 방식을 쓰는 것이 유용할 것이다.
         // 그렇지만 조심할 것은 이것 또한 가스를 소모한다는 점.
         throw;
     }
     voters[ voter ].weight = 1;
 }

 /// 자신의 투표권을 ‘to’에게 위임한다.
 function delegate(address to){
     //참조 할당
     Voter sender = voters[ msg.sender ];
     if( sender.voted )
     throw;

     // ‘to’가 자신의 권한을 위임한 사람을 계속 찾아 들어간다
     // 일반적으로 이와 같은 무척 위험한데, 만약 이러한 루프가 너무 길어지만
     // 블록 내에서 가용한 가스 범위보다 더 많은 가스를 소모할 수 있기 때문이다.
     // 이 경우에 위임은 실행되지 않을 것이지만,
     // 다른 경우에 이러한 루프가 영원히 동작하지 않을(stuck) 수도 있다.
     while (
             voters[to].delegate != address(0) &&
             voters[to].delegate != msg.sender
         ){
             to = voters[to].delegate;
         }

     // 스스로에게 위임 하는 것은 허용되지 않는다.
     if (to == msg.sender) {
         throw;
     }

     // ‘sender’가 참조되었기 때문에
     // 이 명령은 ‘voters[msg.sender].voted’를 변경시킨다
     sender.voted = true;
     sender.delegate = to;
     Voter delegate = voters[to];

     if( delegate.voted ) {
         //만약 위임받는 사람이 이미 투표를 했다면
         // 안건에 투표 숫자를 직접 늘린다
         proposals[delegate.vote].voteCount += sender.weight;
     } else {
         // 만약 위임 받는 사람이 투표를 하지 않았다면
         // 위임 받는 사람의 weight값을 늘린다.
         delegate.weight += sender.weight;
     }
 }



 ///보유하고 있는 투표권을(위임 받은 것 포함)
 ///안건 ‘proposals[proposal].name’에 행사한다.

 function vote(uint proposal){
     Voter sender = voters[msg.sender];
     if (sender.voted)
         throw;
     sender.voted = true;
     sender.vote = proposal;

     // 만약 ‘proposal’이 배열에 존재하지 않는다면
     // 자동으로 예외가 던져지고 모든 실행내용이 원상복구될것이다.
     proposals[proposal].voteCount += sender.weight;
 }
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
function getArray() constant returns (bytes32[10])
    {
        for(uint i=0;i<proposals.length;i++){
            bytesArray[i]=proposals[i].name;
        }
        return bytesArray;
    }

 /// @dev 가장 많은 수를 득표한 안건을 선택한다.
 function winningProposals () constant returns (uint winningProposal) {
     uint winningVoteCount = 0;
     for (uint p = 0; p < proposals.length; p++) {
         if (proposals[p].voteCount > winningVoteCount){
             winningVoteCount = proposals[p].voteCount;
             winningProposal = p;
         }
     }
 }
}
