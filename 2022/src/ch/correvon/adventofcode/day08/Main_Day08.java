package ch.correvon.adventofcode.day08;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class Main_Day08
{
	public static void main(String[] args)
	{
		int result = parseFile(getFileStream("data.txt"), false);
		System.out.println("Résult Part A : " + result);
		// Result Part A : 1647

		result = parseFile(getFileStream("data.txt"), true);
		System.out.println("\n\nResult Part B: " + result);
		// Result Part B: 392080
	}

	private static InputStream getFileStream(String fileName)
	{
		InputStream inputStream = Main_Day08.class.getResourceAsStream(fileName);
		if(inputStream == null)
			System.err.println("Unable to open " + fileName);
		return inputStream;
	}

	private static int parseFile(InputStream inputStream, boolean partB)
	{
		List<String> taForetEnString = new ArrayList<>();
		try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream)))
		{
			String line;
			int lineNum = 0;
			line:while((line = br.readLine()) != null)
			{
				System.out.println("\nline : " + line);
				taForetEnString.add(line);

				lineNum++;
			}
			
			int width = taForetEnString.get(0).length();
			int height = taForetEnString.size();
			int[][] forest = new int[width][height];
			
			lineNum = 0;
			for(String treeLine:taForetEnString)
			{
				char[] treeLineEnChar = treeLine.toCharArray();
				for(int i = 0; i < treeLineEnChar.length; i++)
					forest[lineNum][i] = treeLineEnChar[i] - '0';
				lineNum++;
			}
			
			System.out.println("Forest : ");
			for(int i = 0; i < width - 0; i++)
			{
				for(int j = 0; j < height - 0; j++)
					System.out.print(" "+forest[i][j]+" ");
				System.out.println("");
			}
			System.out.println("");
			
			if(partB)
				return highestTreeScore_partB(forest, width, height);
			return sumOfVisibleTree_partA(forest, width, height);
		}
		catch(IOException e)
		{
			System.err.println("Unable to parse the file :");
			e.printStackTrace();
		}
		
		return 0;
	}
	
	public static int highestTreeScore_partB(int[][] forest, int width, int height)
    {
		int max = 0;
		
		for(int i = 1; i < width - 1; i++)
			for(int j = 1; j < height - 1; j++)
			{
				int score = calculTreeScore(forest, i, j, width, height);
				System.out.print("\nTree score : "+score);
				if(score > max)
				{
					System.out.println(" New Max /!\\");
					max = score;
				}
			}
				
		
		return max;
    }
	
	public static int calculTreeScore(int[][] forest, int i, int j, int width, int height)
	{
		int tree = forest[j][i];
		System.out.println("\nCalculating score for ["+tree+"] at pos ("+i+","+j+")");
		
		// Checking to top border
		System.out.println("To the top : ");
		int ii = i;
		int topScore = 0;
		for(int jj = j - 1; jj >= 0; jj--)
		{
			topScore++;
			if(forest[jj][ii] < tree || jj == 0)
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is lower than ["+tree+"], topScore +1");
			else
			{
				System.out.println("View is blocked by ["+forest[jj][ii]+"] ("+jj+","+ii+")");
				break;
			}
		}
		System.out.println("topScore : "+topScore);

		// Checking to left border
		System.out.println("To the left : ");
		int jj = j;
		int leftScore = 0;
		for(ii = i - 1; ii >= 0; ii--)
		{
			leftScore++;
			if(forest[jj][ii] < tree || ii == 0)
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is lower than ["+tree+"], leftScore +1");
			else
			{
				System.out.println("View is blocked by ["+forest[jj][ii]+"] ("+jj+","+ii+")");
				break;
			}
		}
		System.out.println("leftScore : "+leftScore);

		// Checking to bottom border
		System.out.println("To bottom : ");
		ii = i;
		int bottomScore = 0;
		for(jj = j + 1; jj < height; jj++)
		{
			bottomScore++;
			if(forest[jj][ii] < tree || jj == height - 1)
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is lower than ["+tree+"], bottomScore +1");
			else
			{
				System.out.println("View is blocked by ["+forest[jj][ii]+"] ("+jj+","+ii+")");
				break;
			}
		}
		System.out.println("bottomScore : "+bottomScore);

		// Checking to right border
		System.out.println("To the right : ");
		jj = j;
		int rightScore = 0;
		for(ii = i + 1; ii < width; ii++)
		{
			rightScore++;
			if(forest[jj][ii] < tree || ii == height - 1)
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is lower than ["+tree+"], rightScore +1");
			else
			{
				System.out.println("View is blocked by ["+forest[jj][ii]+"] ("+jj+","+ii+")");
				break;
			}
		}
		System.out.println("rightScore : "+rightScore);

		return leftScore * rightScore * topScore * bottomScore;
	}
	
	public static int sumOfVisibleTree_partA(int[][] forest, int width, int height)
    {
		int sum = width * 2 + (height - 2) * 2; // Borders
		
		for(int i = 1; i < width - 1; i++)
			for(int j = 1; j < height - 1; j++)
				sum += visibleValue(forest, i, j, width, height, sum);
		
		return sum;
    }
	
	private static int visibleValue(int[][] forest, int i, int j, int width, int height, int sum) // sum is just for debuging purpose.
	{
		int tree = forest[j][i];
		System.out.println("\nChecking ["+tree+"] at pos ("+i+","+j+") / Current sum : "+sum);
		
		// Checking from top
		System.out.println("From the top : ");
		boolean higherFound = false;
		int ii = i;
		for(int jj = 0; jj < j; jj++)
		{
			if(forest[jj][ii] >= tree)
			{
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is higher (or equal) than ["+tree+"]");
				higherFound = true;
				break;
			}
		}
		if(!higherFound)
		{
			System.out.println("No higher trees on column "+i);
			return 1;//return tree;
		}

		// Checking from left
		System.out.println("From the left : ");
		higherFound = false;
		int jj = j;
		for(ii = 0; ii < i; ii++)
		{
			if(forest[jj][ii] >= tree)
			{
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is higher (or equal) than ["+tree+"]");
				higherFound = true;
				break;
			}
		}
		if(!higherFound)
		{
			System.out.println("No higher trees on line "+j);
			return 1;//return tree;
		}
		
		// Checking from bottom
		System.out.println("From bottom : ");
		higherFound = false;
		ii = i;
		for(jj = width-1; jj > j; jj--)
		{
			if(forest[jj][ii] >= tree)
			{
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is higher (or equal) than ["+tree+"]");
				higherFound = true;
				break;
			}
		}
		if(!higherFound)
		{
			System.out.println("No higher trees on column "+i);
			return 1;//return tree;
		}
		
		// Checking from right
		System.out.println("From the right : ");
		higherFound = false;
		jj = j;
		for(ii = height-1; ii > i; ii--)
		{
			if(forest[jj][ii] >= tree)
			{
				System.out.println("["+forest[jj][ii]+"] ("+jj+","+ii+")" + " is higher (or equal) than ["+tree+"]");
				higherFound = true;
				break;
			}
		}
		if(!higherFound)
		{
			System.out.println("No higher trees on line "+j);
			return 1;//return tree;
		}

		System.out.println("Tree ["+tree+"] is not visible !!");
		return 0;
	}
}
