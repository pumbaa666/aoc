package ch.correvon.adventofcode.day02.second;

public enum RoundResult
{
	LOSE("X"),
	DRAW("Y"),
	WIN("Z");

	private RoundResult(String label)
	{
		this.label = label;
		this.value = this.label.charAt(0) - "Y".charAt(0);
	}

	public int getValue()
	{
		return this.value;
	}

	public static RoundResult parseEnum(String label)
	{
		for(RoundResult result:RoundResult.values())
			if(result.label.equals(label))
				return result;

		System.err.println("Unable to find Hand : " + label);
		return null;
	}

	public final int value;
	public final String label;
}
