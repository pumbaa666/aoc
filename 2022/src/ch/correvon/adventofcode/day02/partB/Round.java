package ch.correvon.adventofcode.day02.partB;

public class Round
{
	public Round(Hand opponent, RoundResult result)
	{
		this.opponent = opponent;
		this.result = result;
	}

	public int playRound()
	{
		Hand me = null;
		switch(this.result)
		{
			case LOSE : switch(this.opponent) {
				case ROCK : me = Hand.CISOR; break;
				case PAPER : me = Hand.ROCK; break;
				case CISOR : me = Hand.PAPER; break;
			}; break;
			case DRAW : switch(this.opponent) {
				case ROCK : me = Hand.ROCK; break;
				case PAPER : me = Hand.PAPER; break;
				case CISOR : me = Hand.CISOR; break;
			}; break;
			case WIN : switch(this.opponent) {
				case ROCK : me = Hand.PAPER; break;
				case PAPER : me = Hand.CISOR; break;
				case CISOR : me = Hand.ROCK; break;
			}; break;
		}
		
		int winScore = 0;
		int objectScore = me.getValue();
		
		if(me == opponent)
			winScore = 3;
		else		
			switch(me)
			{
				case ROCK : winScore = opponent == Hand.CISOR ? 6 : 0; break;
				case PAPER : winScore = opponent == Hand.ROCK ? 6 : 0; break;
				case CISOR : winScore = opponent == Hand.PAPER ? 6 : 0; break;
			}
		
		System.out.println("This round score : " + (objectScore + winScore) + " ("+objectScore+", "+winScore+")");
		return objectScore + winScore;
	}

	private Hand opponent;
	private RoundResult result;
}
