using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;


namespace JSON_PARSER
{
    class Program
    {        
        //static String json= "{\"glossary\":{\"title\":\"exampleglossary\",\"GlossDiv\":{\"title\":\"S\",\"GlossList\":{\"GlossEntry\":{\"ID\":\"SGML\",\"SortAs\":\"SGML\",\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}}}}";
        static String json= "{\"GlossEntry\":{\"ID\":\"SGML\",\"SortAs\":\"SGML\",\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}";
        static String json_shhadi = "{\"name\":\"shhadi\",\"sex\":\"m,a,l,e\",\"job\":{\"name\":\"software,developer\",\"org\":\"check,point\"},\"age\":29}";

        static void Main(string[] args)
        {

            var result = Parse(json);

        }

        static Dictionary<String, Object> Parse(String input)
        {
            var dictionary = new Dictionary<String, Object>();
            var parts = getObjectParts(input);

            foreach (var part in parts)
            {
                var pair = getPairOfObject(part);
                var key = pair[0];
                var value = pair[1];

                if (!isNull(key))
                {
                    if (isNull(value))
                    {
                        dictionary.Add(key, "");
                    }

                    else if (isString(value) || isNumber(value) || isBoolean(value))
                    {
                        dictionary.Add(key, value);
                    }

                    else if (isArray(value))
                    {
                        var elements = getElementsOfArray(value);
                        var parsedElements = new List<Object>();

                        foreach (var element in elements)
                        {
                            if (isNull(element) || isString(element) || isNumber(element) || isBoolean(element))
                            {
                                parsedElements.Add(element);
                            }
                            else if (isArray(element))
                            {
                                parsedElements.Add(getElementsOfArray(element));
                            }
                            else if (isObject(element))
                            {
                                parsedElements.Add(getPairOfObject(element));
                            }
                        }

                        dictionary.Add(key, parsedElements);
                    }

                    else if (isObject(value))
                    {
                        dictionary.Add(key, Parse(value));
                    }
                    else
                    {
                        var _pair = split(value, ",\"");
                        var _value = _pair[0];
                        var _element = _pair[1];
                        dictionary.Add(key, _value);
                        Parse(_element);
                    }

                }
            }

            return dictionary;
        }
        
        static List<String> getObjectParts(String input)
        {
            var indexes = new List<int>();
            var openedTag = 1;
            var openedString = 0;

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
                        if (openedString == 0 && openedTag == 1)
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
