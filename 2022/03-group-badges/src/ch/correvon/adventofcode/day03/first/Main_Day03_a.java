package ch.correvon.adventofcode.day03.first;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class Main_Day03_a
{

	public static void main(String[] args)
	{
		int score = parseFile(getFileStream("/ch/correvon/adventofcode/day03/data.txt"));
		System.out.println("Score : " + score);
		// Score : 7793
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
		int score = 0;
		
		try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream)))
		{
			String line;
			int lineNum = 0;
			while((line = br.readLine()) != null)
			{
				if(line.length() % 2 != 0)
				{
					System.out.println("WARN : Line " + lineNum + " has not an even length ! " + line + "["+line.length()+"]");
					continue;
				}
				int half = line.length() / 2;
				String compartment1 = line.substring(0, half);
				String compartment2 = line.substring(half, line.length());
				
				score += getSackScore(compartment1, compartment2);
				
				lineNum++;
			}
		}
		catch(IOException e)
		{
			System.err.println("Unable to parse the file :");
			e.printStackTrace();
		}
		
		return score;
	}
	
	private static final int getSackScore(String compartment1, String compartment2)
	{
	    char[] chars1 = compartment1.toCharArray();
	    char[] chars2 = compartment2.toCharArray();
	    int score = 0;
	    
	    for(char c1 : chars1)
		    for(char c2 : chars2)
		    	if(c1 == c2) {
		    		score = c1 < 'a' ? c1 - 'A' + 27 : c1 - 'a' + 1;
		    		System.out.println("Identical char : '"+c1+"'. Score : " + score);
		    		return score;
		    	}

	    System.out.println("WARN : no identical chars in '"+compartment1+"' and '"+compartment1+"'");
		return score;
	}
}
