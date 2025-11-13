
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
        if(split.length() != 2)
        {
            System.err.println("Invalid line : " + line);
            continue;
        }

        try
        {
            this.start = Integer.parseInt(split[0])
            this.end = Integer.parseInt(split[1])
        }
        catch(NumberException e)
        {
            System.err.println("Unable to cast : " + line + " to number");
        }
    }

    private int start;
    private int end;
}