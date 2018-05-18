// int semWord = getsem(1);
// int semFruit = getsem(1);
// if (fork()) {
// 	for (int i = 0; i < TIMES; ++i)
// 	{
// 		// p(semFruit);
// 		// p(semWord);
// 		int2str(fruit, tmpstr);
// 		printSentence("Eat fruit: ", line, 0, strlen("Eat Fruit: "), white);
// 		printSentence(tmpstr, line, strlen("Eat Fruit: "), strlen(tmpstr), white);
// 		printSentence("Word received: ", line, strlen("Eat Fruit: ") + strlen(tmpstr) + 1, strlen("Word received: "), white);
// 		printSentence(word, line++, strlen("Eat Fruit: ") + strlen(tmpstr) + strlen("Word received: ") + 1, strlen(word), white);
// 		// v(semWord);
// 		// v(semFruit);
// 		// printSentence("1", line++, 0, 1, white);
// 		// __asm__("int $0x8\n");

// 	}
// } else {
// 	if (fork()) {
// 		for (int i = 0; i < TIMES; ++i)
// 		{
// 			// p(semFruit);
// 			putFruit();
// 			// v(semFruit);
// 			// __asm__("int $0x8\n");
// 		}
// 	} else {
// 		for (int i = 0; i < TIMES; ++i)
// 		{
// 			// p(semWord);
// 			putWord();
// 			// v(semWord);
// 			// __asm__("int $0x8\n");
// 		}
// 	}
// }
// freesem(semWord);
// freesem(semFruit);