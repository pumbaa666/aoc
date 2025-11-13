package ch.correvon.adventofcode.day02.first;

public class Round
{
	public Round(Hand me, OpponentHand opponent)
	{
		this.me = me;
		this.opponent = opponent;
	}
	
	public int playRound()
	{
		int objectScore = me.getValue();
		int winScore = 0;
		
		if(me.getValue() == opponent.getValue())
			winScore = 3;
		else		
			switch(me)
			{
				case ROCK : winScore = opponent == OpponentHand.CISOR ? 6 : 0; break;
				case PAPER : winScore = opponent == OpponentHand.ROCK ? 6 : 0; break;
				case CISOR : winScore = opponent == OpponentHand.PAPER ? 6 : 0; break;
			}
		
		System.out.println("This round score : " + (objectScore + winScore) + " ("+objectScore+", "+winScore+")");
		return objectScore + winScore;
	}

	private Hand me;
	private OpponentHand opponent;
}
