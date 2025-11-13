package ch.correvon.adventofcode.day02.second;

public enum Result
{
	LOSE("X"),
	DRAW("Y"),
	WIN("Z");

	private Result(String label)
	{
		this.label = label;
		this.value = this.label.charAt(0) - "Y".charAt(0);
	}

	public int getValue()
	{
		return this.value;
	}

	public static Result parseEnum(String label)
	{
		for(Result result:Result.values())
			if(result.label.equals(label))
				return result;

		System.err.println("Unable to find Hand : " + label);
		return null;
	}

	public final int value;
	public final String label;
}
