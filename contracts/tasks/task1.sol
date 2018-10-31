
contract Score {

    uint256 public score;

    function setScore(uint256 _score) external {
        score  = _score;
    }

}


contract ScoreV2 {

    uint256 public score;

    function setScore(uint256 _score) external {
        score  = _score + 1;
    }

}