package ch.correvon.adventofcode.day02.first;

public enum OpponentHand
{
	ROCK("A"),
	PAPER("B"),
	CISOR("C");

	private OpponentHand(String label)
	{
		this.label = label;
		this.value = this.label.charAt(0) - "A".charAt(0) + 1;
	}

	public int getValue()
	{
		return this.value;
	}

	public static OpponentHand parseEnum(String label)
	{
		for(OpponentHand result:OpponentHand.values())
			if(result.label.equals(label))
				return result;

		System.err.println("Unable to find Hand : " + label);
		return null;
	}

	public final int value;
	public final String label;
}
