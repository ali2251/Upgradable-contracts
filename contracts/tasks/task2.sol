

contract ScoreStorage {

    uint256 public score;

    function setScore(uint256 _newScore) external {
        score = _newScore;
    }

}

contract Score {

    ScoreStorage ss;

    constructor(address scoreStorage) {
        ss = ScoreStorage(scoreStorage);
    }

    function setScore(uint256 _score) external {
        ss.setScore(_score);
    }

}


contract ScoreV2 {

    ScoreStorage ss;

    constructor(address scoreStorage) {
        ss = ScoreStorage(scoreStorage);
    }

    function setScore(uint256 _score) external {
        ss.setScore(_score + 1);
    }

}
