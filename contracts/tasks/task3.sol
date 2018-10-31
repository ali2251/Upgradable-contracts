

contract ScoreStorage {

    mapping(bytes32 => uint256) uints;

    function setUint(bytes32 _key , uint256 _newScore) external {
        uints[_key] = _newScore;
    }

    function getUint(bytes32 _key) external returns(uint256) {
        return uints[_key];
    }

}

contract Score {

    ScoreStorage ss;
    bytes32 public constant SCORE = keccak256("score");

    constructor(address scoreStorage) {
        ss = ScoreStorage(scoreStorage);
    }

    function setScore(uint256 _score) external {
        ss.setUint(SCORE,_score);
    }

}



contract ScoreV2 {

    ScoreStorage ss;
    bytes32 public constant SCORE = keccak256("score");

    constructor(address scoreStorage) {
        ss = ScoreStorage(scoreStorage);
    }

    function setScore(uint256 _score) external {
        ss.setUint(SCORE,_score + 1);
    }

}
