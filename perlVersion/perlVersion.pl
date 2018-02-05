

		

        #my $json= "{\"glossary\":{\"title\":\"exampleglossary\",\"GlossDiv\":{\"title\":\"S\",\"GlossList\":{\"GlossEntry\":{\"ID\":\"SGML\",\"SortAs\":\"SGML\",\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}}}}";
        my $json = "{\"GlossEntry\":{\"ID\":\"SGML\",\"SortAs\":\"SGML\",\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}";
        my $json2 = "{\"GlossEntry\":{\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}";
        my $json_shhadi = "{\"name\":\"shhadi\",\"sex\":\"m,a,l,e\",\"job\":{\"name\":\"software,developer\",\"org\":\"check,point\"},\"age\":29}";

        #static void Main(string[] args)
		sub Main
        {

            my $result = Parse($json2);

        }

        #static Dictionary<String, Object> Parse(String input)
		sub Parse()
        {
			my ($input) = @_;
			my %dictionary;
            my @parts = getObjectParts(input);

			foreach $part (@parts)
            {
                my @pair = getPairOfObject($part);
                my $key = $pair[0];
                my $value = $pair[1];

                if (!isNull($key))
                {
                    if (isNull($value))
                    {
						dictionary{$key} = "";
                    }

                    else if (isString(value) || isNumber(value) || isBoolean(value))
                    {
						dictionary{$key} = $value;
                    }

                    else if (isArray(value))
                    {
                        my @elements = getElementsOfArray(value);
                        my @parsedElements;

                        foreach $element (@elements)
                        {
                            if (isNull($element) || isString($element) || isNumber($element) || isBoolean($element))
                            {	
                                push(@parsedElements,$element);
                            }
                            else if (isArray($element))
                            {
                                push(@parsedElements,getElementsOfArray($element));
                            }
                            else if (isObject($element))
                            {
                                push(@parsedElements,getPairOfObject($element));
                            }
                        }
							
						
                        dictionary{$key} = $parsedElements;
                        
                    }

                    else if (isObject($value))
                    {
                        dictionary{$key} = Parse($value));
                    }
                    else
                    {
                        @_pair = split($value, ",\"");
                        my $_value = $_pair[0];
                        my $_element = $_pair[1];
                        dictionary{key} = $_value;
                        Parse($_element);
                    }

                }
            }

            return %dictionary;
        }
        
        #static List<String> getObjectParts(String input)
        sub getObjectParts
		{
			my $input = $_[0];
            my @indexes;   # = new List<int>();
            my $openedTag = 1;    #'{'
            my $openedString = 0; #'"'
            my $openedArray = 0;  #'['

            $input = removeTags($input);

            for (my $i=0;$i<length $input;$i++)
            {
                my $ch = $input[$i];

                if($ch=='{')
				{
					$openedTag = $openedTag + 1;
				}
				if($ch=='}')
                {
                    $openedTag = $openedTag - 1;
                }
				if($ch=='[')
                {
                    $openedArray = $openedArray+1;
                }
				if($ch==']')
				{
                    $openedArray = $openedArray-1;
                }
				if($ch=='"')
                {
                    if ($openedString == 0)
                    {
                        $openedString = $openedString + 1;   #String started.
                    }
                    else
                    {
                        $openedString = 0;    #String closed.
                    }
                }
				if($ch==',')
				{
                    if ($openedString == 0 && $openedArray==0 && $openedTag == 1)
                    {
						push $indexes,$i;
                    }
                    else
                    {
                        continue;
                    }
                }
        

            my @parts =   split1($input, $indexes);

            return @parts;
        }

        #static String removeTags(String input)
		sub removeTags
        {
			my $input = $_[0];
            my $result = substr $input,1,$length $input -1;    # input.Substring(1);
                                                               #result = result.Substring(0, result.Length - 1);
            return $result;
        }

        #static List<String> split1(String input,List<int> indexes)
		sub split1
       {
			my $input = $_[0];
			my @indexes = $_[1];
            my @parts;
            my $count = length $indexes;

            for (my $i = 0; i < $count; $i++)
            {
                //[3,8]
                my $part = "";

                if ($i == 0 )
                {
                    $part = substr $input,0,$indexes[i];       # input.Substring(0, indexes[i]);
                    $input = substr $input,$indexese[i]+1,length $input -1       # input.Substring(indexes[i] + 1);
                }
                else
                {
                    $part = substr $input,0,$indexes[$i] - $indexes[$i - 1] - 1;      #input.Substring(0, indexes[i] - indexes[i - 1] - 1);
                    $input = substr $input,$indexes[$i] - $indexes[$i - 1],length $input -1;    #input.Substring(indexes[i] - indexes[i - 1] );
                }
				
				push @parts,$part;
                #parts.Add(part);
            }

			push @parts,$input;
            #parts.Add(input);
            return @parts;
        }

        #static List<String> split2(String input, String separator)
		sub split2
        {
            //{123:5}
			my $input = $_[0];
			my $separator = $_[1];
			
            my @pair;
            my $index = index($input,$separator);  #input.IndexOf(separator);  //4

            if ($index >= 0)
            {
                my $key = substr $input,1,$index;      #input.Substring(1, index - 1);
                my $value = substr $input,$index+1,length $input-$index-2;       #input.Substring(index + 1, input.Length - index - 2);
                my @pair;
				push @pair,$key;
				push @pair,$value;
								#pair = new List<String>() { key, value };
            }
            return @pair;
        }

        #static List<String> split3(String input,char separator)
		sub split3
        {
			my $input = $_[0];
			my $separator = $_[1];
            //{123:5}
            my $index = index($input,$separator,0);   # input.IndexOf(separator);  //4
            my $key = substr $input,1,$index -1  #input.Substring(1, index - 1);
            my $value = substr $input,$index+1,length $input-$index-2;     # input.Substring(index + 1, input.Length - index - 2);
            my @pair;
			push @pair,$key;
			push @pair,$value;
										#my $pair = new List<String>() { key, value };
            return @pair;
        }

        
        #static Boolean isNull(String input)
		sub isNull
        {
			my $input = $_[0];
            return $input == "" || $input == "null";
        }

        #static Boolean isString(String input)
		sub isString
        {
			my $input = $_[0];
			@array = split // , $input;
            return $array[0] == '"' && $array[length $array - 1] == '"';
        }

        #static Boolean isNumber(String input)
        #{
        #    int x;
        #    return int.TryParse(input, out x);
        #}

        #$static Boolean isBoolean(String input)
		sub isBoolean
        {	
			my $input = $_[0];
            return $input == "true" || $input == "false";
        }

        #static Boolean isObject(String input)
		sub isObject
        {
			my $input = $_[0];
			@array = split // , $input;
            return $array[0] == '{' && $array[length $array - 1] == '}';
        }

        #static Boolean isArray(String input)
        sub isArray
		{
			my $input = $_[0];
			@array = split // , $input;
            return $array[0] == '[' && $array[length $array - 1] == ']';
        }

        #static List<String> getPairOfObject(String input)
		sub getPairOfObject
        {
			my $input = $_[0];
            //{123:5}
            my $index = index($input,':',0);
            my $key = substr $input,1,$index - 3;
            my $value = substr $input,,index + 1, length $input - $index - 2);
			my @pair;
			push @pair,$key;
			push @pair,$value;
            return @pair;
        }

        #static List<String> getElementsOfArray(String input)
		sub getElementsOfArray
        {
			$input = $_[0];
            //[123,5]
            my @elements = split /[,\[\]]/ , $input;
            return @elements;
        }
    }
}
