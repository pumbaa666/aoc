package ch.correvon.adventofcode.day03.first;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Main_Day04_a
{

	public static void main(String[] args)
	{
		int overlapping = parseFile(getFileStream("/ch/correvon/adventofcode/day04/data.txt"));
		System.out.println("Overlapping elfes : " + overlapping);
		// Overlapping elfes : 
	}

	private static InputStream getFileStream(String fileName)
	{
		InputStream inputStream = Main_Day03_a.class.getResourceAsStream(fileName);
		if(inputStream == null)
			System.err.println("Unable to open " + fileName);
		return inputStream;
	}

	private static int parseFile(InputStream inputStream)
	{
		int nbOverlapping = 0;
		
		try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream)))
		{
			String line;
			int lineNum = 0;
			while((line = br.readLine()) != null)
			{
				String[] split = line.split(",");
				if(split.length() != 2)
				{
					System.err.println("Invalid line " + lineNum + " : " + line);
					continue;
				}

				Shift shift1 = Shift.parseShift(split[0]);
				Shift shift2 = Shift.parseShift(split[1]);
				nbOverlapping += isOverlapping(shift1, shift2);
				
				lineNum++;
			}
		}
		catch(IOException e)
		{
			System.err.println("Unable to parse the file :");
			e.printStackTrace();
		}
		
		return nbOverlapping;
	}
	
	private static final int isOverlapping(String shift1, String shift2)
	{
	    return (shift1.start >= shift2.start && shift1.end <= shift2.end) || (shift2.start >= shift1.start && shift2.end <= shift1.end) ;
	}
}
