package ch.correvon.adventofcode.day04;

import java.awt.Point;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Main_Day04
{

	public static void main(String[] args)
	{
		Point overlappings = parseFile(getFileStream("data.txt"));
		System.out.println("Overlapping elfes Part A : " + overlappings.x);
		// Overlapping elfes : 573

		System.out.println("Overlapping elfes Part B : " + overlappings.y);
		// Overlapping elfes : 867
	}

	private static InputStream getFileStream(String fileName)
	{
		InputStream inputStream = Main_Day04.class.getResourceAsStream(fileName);
		if(inputStream == null)
			System.err.println("Unable to open " + fileName);
		return inputStream;
	}

	private static Point parseFile(InputStream inputStream)
	{
		int nbOverlappingA = 0;
		int nbOverlappingB = 0;
		
		try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream)))
		{
			String line;
			int lineNum = 0;
			while((line = br.readLine()) != null)
			{
				String[] split = line.split(",");
				if(split.length != 2)
				{
					System.err.println("Invalid line " + lineNum + " : " + line);
					continue;
				}

				Shift shift1 = Shift.parseShift(split[0]);
				Shift shift2 = Shift.parseShift(split[1]);
				if(isOverlapping_partA(shift1, shift2)) {
					System.out.println("Overlaping A : " + lineNum + " : " + line);
					nbOverlappingA++;
				}
				
				if(isOverlapping_partB(shift1, shift2)) {
					System.out.println("Overlaping B : " + lineNum + " : " + line);
					nbOverlappingB++;
				}

				lineNum++;
			}
		}
		catch(IOException e)
		{
			System.err.println("Unable to parse the file :");
			e.printStackTrace();
		}
		
		return new Point(nbOverlappingA, nbOverlappingB); // Return both result at the same time. In a Point for ease
	}
	
	private static final boolean isOverlapping_partA(Shift shift1, Shift shift2)
	{
	    return (shift1.getStart() >= shift2.getStart() && shift1.getEnd() <= shift2.getEnd()) || (shift2.getStart() >= shift1.getStart() && shift2.getEnd() <= shift1.getEnd());
	}
	
	private static final boolean isOverlapping_partB(Shift shift1, Shift shift2)
	{
	    return (shift1.getStart() >= shift2.getStart() && shift1.getEnd() <= shift2.getEnd()
    			|| (shift2.getStart() >= shift1.getStart() && shift2.getEnd() <= shift1.getEnd())
    			|| (shift1.getEnd() >= shift2.getStart() && shift1.getEnd() <= shift2.getEnd())
    			|| (shift1.getStart() >= shift2.getStart() && shift1.getStart() <= shift2.getEnd())
    			);
	}
}
