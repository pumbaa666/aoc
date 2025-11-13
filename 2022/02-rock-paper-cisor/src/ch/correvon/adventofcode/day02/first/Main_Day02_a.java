package ch.correvon.adventofcode.day02.first;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class Main_Day02_a
{

	public static void main(String[] args)
	{
		int score = playGame(parseFile(getFileStream("/data.txt")));
		System.out.println("Mon score final : " + score);
		// Mon score final : 13009
	}

	private static InputStream getFileStream(String fileName)
	{
		InputStream inputStream = Main_Day02_a.class.getResourceAsStream(fileName);
		if(inputStream == null)
			System.err.println("Unable to open " + fileName);
		return inputStream;
	}

	private static List<Round> parseFile(InputStream inputStream)
	{
		List<Round> rounds = new ArrayList<>();
		
		try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream)))
		{
			String line;
			int lineNum = 0;
			while((line = br.readLine()) != null)
			{
				String[] roundArray = line.split(" ");
				if(roundArray.length != 2)
				{
					System.out.println("WARN : Unable to parse " + line + " at line " + lineNum);
					continue;
				}
				
				Round round = new Round(Hand.parseEnum(roundArray[1]), OpponentHand.parseEnum(roundArray[0]));
				rounds.add(round);
				lineNum++;
			}
		}
		catch(IOException e)
		{
			System.err.println("Unable to parse the file :");
			e.printStackTrace();
		}
		
		return rounds;
	}
	
	private static int playGame(List<Round> rounds)
	{
		return rounds.stream().map(round -> round.playRound()).reduce(0, Integer::sum);
	}
}
