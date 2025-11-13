package ch.correvon.adventofcode.day02.first;

public enum Hand
{
	ROCK("X"),
	PAPER("Y"),
	CISOR("Z");

	private Hand(String label)
	{
		this.label = label;
		this.value = this.label.charAt(0) - "X".charAt(0) + 1;
	}

	public int getValue()
	{
		return this.value;
	}
	
	public String getLabel()
	{
		return this.toString() + " ("+this.value+")";
	}

	public static Hand parseEnum(String label)
	{
		for(Hand hand:Hand.values())
			if(hand.label.equals(label))
				return hand;

		System.err.println("Unable to find Hand : " + label);
		return null;
	}
	
	public final int value;
	public final String label;
}
