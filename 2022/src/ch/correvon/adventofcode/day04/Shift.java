package ch.correvon.adventofcode.day04;

public class Shift
{
    public Shift(int start, int end)
    {
        this.start = start;
        this.end = end;
    }

    public static Shift parseShift(String line)
    {
        String[] split = line.split("-");
        if(split.length != 2)
        {
            System.err.println("Invalid line : " + line);
            return null;
        }

        try
        {
            int start = Integer.parseInt(split[0]);
            int end = Integer.parseInt(split[1]);
            return new Shift(start, end);
        }
        catch(NumberFormatException e)
        {
            System.err.println("Unable to cast : " + line + " to number");
        }
        
        return null;
    }
    
    public int getStart()
    {
    	return this.start;
    }
    
    public int getEnd()
    {
    	return this.end;
    }

    private int start;
    private int end;
}