

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
        
        static List<String> getObjectParts(String input)
        {
            var indexes = new List<int>();
            var openedTag = 1;
            var openedString = 0;
            var openedArray = 0;

            input = removeTags(input);

            for (int i=0;i<input.Length;i++)
            {
                var ch = input[i];

                switch (ch)
                {
                    case '{':
                        openedTag++;
                        break;
                    case '}':
                        openedTag--;
                        break;
                    case '[':
                        openedArray++;
                        break;
                    case ']':
                        openedArray--;
                        break;
                    case '"':
                        if (openedString == 0)
                        {
                            openedString++;   //String started.
                            //stringStartIndex = i;
                        }
                        else
                        {
                            openedString = 0;  //String closed.
                            //stringEndIndex = i;
                        }
                        break;
                    //case ':':
                      //  continue;
                    case ',':
                        if (openedString == 0 && openedArray==0 && openedTag == 1)
                        {
                            indexes.Add(i);
                        }
                        else
                        {
                            continue;
                        }
                        break;
                }
            }

            var parts = split(input, indexes);

            return parts;
        }

        static String removeTags(String input)
        {
            var result = input.Substring(1);
            result = result.Substring(0, result.Length - 1);
            return result;
        }

        static List<String> split(String input,List<int> indexes)
        {
            var parts = new List<String>();
            var count = indexes.Count;

            for (int i = 0; i < count; i++)
            {
                //[3,8]
                var part = "";

                if (i == 0 )
                {
                    part = input.Substring(0, indexes[i]);
                    input = input.Substring(indexes[i] + 1);
                }
                else
                {
                    part = input.Substring(0, indexes[i] - indexes[i - 1] - 1);
                    input = input.Substring(indexes[i] - indexes[i - 1] );
                }
                /*
                else if (i == 0 && count > 1)
                {
                    part0 = input.Substring(indexes[i], indexes[i]);
                }
                */
                parts.Add(part);
            }

            parts.Add(input);
            return parts;
        }

        static List<String> split(String input, String separator)
        {
            //{123:5}

            var pair = new List<String>();
            var index = input.IndexOf(separator);  //4

            if (index >= 0)
            {
                var key = input.Substring(1, index - 1);
                var value = input.Substring(index + 1, input.Length - index - 2);
                pair = new List<String>() { key, value };
            }
            return pair;
        }

        static List<String> split(String input,char separator)
        {
            //{123:5}
            var index = input.IndexOf(separator);  //4
            var key = input.Substring(1, index - 1);
            var value = input.Substring(index + 1, input.Length - index - 2);
            var pair = new List<String>() { key, value };
            return pair;
        }

        

        static Boolean isNull(String input)
        {
            return input == "" || input == "null";
        }

        static Boolean isString(String input)
        {
            return input[0] == '"' && input[input.Length - 1] == '"';
        }

        static Boolean isNumber(String input)
        {
            int x;
            return int.TryParse(input, out x);
        }

        static Boolean isBoolean(String input)
        {
            return input == "true" || input == "false";
        }

        static Boolean isObject(String input)
        {
            return input[0] == '{' && input[input.Length - 1] == '}';
        }

        static Boolean isArray(String input)
        {
            return input[0] == '[' && input[input.Length - 1] == ']';
        }

        static List<String> getPairOfObject(String input)
        {
            //{123:5}
            var index = input.IndexOf(':');  //4
            var key = input.Substring(1, index - 2);
            var value = input.Substring(index + 1, input.Length - index - 1);
            var pair = new List<String>() { key, value };
            return pair;
        }

        static List<String> getElementsOfArray(String input)
        {
            //[123,5]
            var elements = input.Split(new char[] { ',', '[', ']' }, StringSplitOptions.RemoveEmptyEntries);
            return elements.ToList();
        }
    }
}
