contract CounterMaster{
    mapping(address => Counter) private counters;
    address[] private addressList;
    
    function addCounter(bytes32 name)
    {
        Counter c = new Counter(name);
        addressList.push(address(c));
        counters[address(c)] = c;
    }
    function getCounterAddressList() constant returns
    (address[] counterAddressList){
        counterAddressList = addressList;
    }
}

contract Counter{
    bytes32 counterName;
    uint32 numberOfCounter;
    
    function Counter(bytes32 name)
    {
        counterName = name;
    }
    
    function countUp()
    {
        numberOfCounter++;
    }
    function getCounterName() constant returns (bytes32 name){
        return counterName;
    }
    function getNumberOfCounter() constant returns (uint32 number){
        return numberOfCounter;
    }
}
