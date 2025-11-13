package ch.correvon.adventofcode.day05;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class Main_Day05
{
	private static final String[] crateEnString = new String[] {
		"JHGMZNTF",
		"VWJ",
		"GVLJBTH",
		"BPJNCDVL",
		"FWSMPRG",
		"GHCFBNVM",
		"DHGMR",
		"HNMVZD",
		"GNFH"
	};
	
	private static List<List<Character>> convertCratesStringToList()
	{
		List<List<Character>> crates = new ArrayList<>(crateEnString.length);
		for(String crate:crateEnString)
			crates.add(crate.chars().mapToObj(c -> (char) c).collect(Collectors.toList()));
		return crates;
	}

	public static void main(String[] args)
	{
		List<List<Character>> crates = convertCratesStringToList();
		String topElves = getTopElvesFromTheShelves(parseFile(crates, getFileStream("data.txt"), false));
		System.out.println("Top elfves on the shelf : " + topElves);
		// Top elfves on the shelf : TDCHVHJTG
		
		crates = convertCratesStringToList();
		topElves = getTopElvesFromTheShelves(parseFile(crates, getFileStream("data.txt"), true));
		System.out.println("Top elfves on the shelf : " + topElves);
		// Top elfves on the shelf : NGCMPJLHV
	}

	private static InputStream getFileStream(String fileName)
	{
		InputStream inputStream = Main_Day05.class.getResourceAsStream(fileName);
		if(inputStream == null)
			System.err.println("Unable to open " + fileName);
		return inputStream;
	}

	private static List<List<Character>> parseFile(List<List<Character>> crates, InputStream inputStream, boolean partB)
	{
		try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream)))
		{
			String line;
			int lineNum = 0;
			while((line = br.readLine()) != null)
			{
				String[] split = line.split(" ");
				if(split.length != 6)
				{
					System.err.println("Invalid line " + lineNum + " : " + line);
					continue;
				}
				
				int nbCratesToMove;
				int moveFromPosition;
				int moveToPosition;
				try
				{
					nbCratesToMove = Integer.parseInt(split[1]);
					moveFromPosition = Integer.parseInt(split[3]) - 1;
					moveToPosition = Integer.parseInt(split[5]) - 1;
				}
				catch(NumberFormatException e)
				{
					System.err.println("Invalid line " + lineNum + " : " + line);
					continue;
				}
				
				if(partB)
					applyMoves_partB(crates, nbCratesToMove, moveFromPosition, moveToPosition);
				else
					applyMoves_partA(crates, nbCratesToMove, moveFromPosition, moveToPosition);

				lineNum++;
			}
		}
		catch(IOException e)
		{
			System.err.println("Unable to parse the file :");
			e.printStackTrace();
		}
		
		return crates;
	}
	
	private static void applyMoves_partA(List<List<Character>> crates, int nbCratesToMove, int moveFromPosition, int moveToPosition)
	{
		for(int i = 0; i < nbCratesToMove; i++)
			crates.get(moveToPosition).add(crates.get(moveFromPosition).remove(crates.get(moveFromPosition).size()-1));
	}	
	
	private static void applyMoves_partB(List<List<Character>> crates, int nbCratesToMove, int moveFromPosition, int moveToPosition)
	{
		for(int i = 0; i < nbCratesToMove; i++)
			crates.get(moveToPosition).add(crates.get(moveToPosition).size() - i, crates.get(moveFromPosition).remove(crates.get(moveFromPosition).size()-1));
	}	

	private static String getTopElvesFromTheShelves(List<List<Character>> crates)
	{
		StringBuilder sb = new StringBuilder();
		for(List<Character> crate:crates)
			sb.append(crate.get(crate.size()-1));
		return sb.toString();
	}
}
