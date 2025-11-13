package ch.correvon.adventofcode.day03;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class Main_Day03
{

	public static void main(String[] args)
	{
		int score = parseFile_partA(getFileStream("data.txt"));
		System.out.println("Score Part A : " + score);
		// Score : 7793
		
		score = parseFile_partB(getFileStream("data.txt"));
		System.out.println("Score Part B : " + score);
		// Score : 2499

	}

	private static InputStream getFileStream(String fileName)
	{
		InputStream inputStream = Main_Day03.class.getResourceAsStream(fileName);
		if(inputStream == null)
			System.err.println("Unable to open " + fileName);
		return inputStream;
	}

	private static int parseFile_partA(InputStream inputStream)
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
				
				score += getSackScore_partA(compartment1, compartment2);
				
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
	
	private static final int getSackScore_partA(String compartment1, String compartment2)
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
	
	private static int parseFile_partB(InputStream inputStream)
	{
		int score = 0;
		
		try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream)))
		{
			String line;
			int lineNum = 0;
			List<String> elvesGroup = new ArrayList<>(3);
			while((line = br.readLine()) != null)
			{
				if(line.length() % 2 != 0)
				{
					System.out.println("WARN : Line " + lineNum + " has not an even length ! " + line + "["+line.length()+"]");
					continue;
				}
				elvesGroup.add(line);
				
				if((lineNum + 1) % 3 == 0) {
					score += getSackScore_partB(elvesGroup);
					elvesGroup.clear();
				}
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
	
	private static final int getSackScore_partB(List<String> elvesGroup)
	{
		List<Map<Character, Integer>> maps = new ArrayList<>(elvesGroup.size());
		
		// Mapping
		for(String elf:elvesGroup)
		{
		    char[] chars = elf.toCharArray();
		    
			Map<Character, Integer> map = new HashMap<>();
			for(char c:chars)
			{
				if(map.containsKey(c))
				{
					int counter = map.get(c);
					map.put(c, ++counter);
				}
				else
					map.put(c, 1);
			}
			maps.add(map);
		}
		
		// Check identical
		for(char c:elvesGroup.get(0).toCharArray())
			if(maps.get(1).containsKey(c) && maps.get(2).containsKey(c))
				return c < 'a' ? c - 'A' + 27 : c - 'a' + 1;

		System.err.println("Unable to find correspondance in all 3 sacks");
		return 0;
	}
}
