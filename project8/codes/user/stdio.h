void printSentence(char * message, int x, int y, int len, int color);

void int2str(int org, char * str)
{
	int num = 0;
	int cp = org;
	while (cp != 0)
	{
		cp /= 10;
		++num;
	}
	if (org == 0)
		num = 1;
	str[num--] = '\0';
	for (int i = num; i >= 0; --i)
	{
		str[i] = org % 10 + 48;
		org /= 10;
	}
}

int strlen(char * sen)
{
	int i = 0;
	while (sen[i]) { ++i; }
	return i;
}

char getchar();

void clear();