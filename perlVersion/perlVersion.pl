use Data::Dumper;

Main();

%object;

#static void Main(string[] args)
sub Main
{
	#my $json= "{\"glossary\":{\"title\":\"exampleglossary\",\"GlossDiv\":{\"title\":\"S\",\"GlossList\":{\"GlossEntry\":{\"ID\":\"SGML\",\"SortAs\":\"SGML\",\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}}}}";
	$json = "{\"GlossEntry\":{\"ID\":\"SGML\",\"SortAs\":\"SGML\",\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}";
	$json2 = "{\"GlossEntry\":{\"GlossTerm\":\"StandardGeneralizedMarkupLanguage\",\"Acronym\":\"SGML\",\"Abbrev\":\"ISO8879:1986\",\"GlossDef\":{\"para\":\"Ameta-markuplanguage,usedtocreatemarkuplanguagessuchasDocBook.\",\"GlossSeeAlso\":[\"GML\",\"XML\"]},\"GlossSee\":\"markup\"}}";
	$json_shhadi = "{\"name\":\"shhadi\",\"sex\":\"m,a,l,e\",\"job\":{\"name\":\"software,developer\",\"org\":\"check,point\"},\"age\":29}";
    $json_arr="{\"name\":\"shhadi\",\"languages\":[\"JAVA\",\"PERL\"],\"sex\":\"m,a,l,e\",\"job\":{\"name\":\"software,developer\",\"org\":\"check,point\"},\"age\":29}";
    my $fake_json="{\"name\":\"shhadi\",\"languages\":[{\"id1\":\"JAVA\"},{\"id2\":\"PERL\"}]}";



    my $fake_json1="{\"name\":\"shhadi\"}";
    my $fake_json2="{\"languages\":[\"id1\",\"id2\"]}";
    my $fake_json3="{\"name\":{\"id1\":\"JAVA\"}}";


    print "111:";
	Parse($fake_json1);		
	print Dumper(\%object);	
	my $o1 = $object{name};		
	print "$o1";	


	print "222:";
	Parse($fake_json2);		
	print Dumper(\%object);	
	my @o2 = $object{languages};		
    print Dumper(\@o2);	

	print "333:";
	Parse($fake_json3);		
	print Dumper(\%object);	
	my %o3 = $object{name};		
    print Dumper(\%o3);	
	
    print "=========================";
    #foreach $nextItem (@{$result{fields}{issuelinks}}) 
    #{
    #    print Dumper(@nextItem);
	#}
	
}

# Contains RN:          https://jira-prd.checkpoint.com/rest/api/2/issue/MET-868?fields=key,status,assignee,issuetype,summary,fixVersions,issuelinks
# Contains Children:    



#static Dictionary<String, Object> Parse(String input)
sub Parse
{
	my $input = $_[0];
	my %dictionary =();
    my @parts = getObjectParts($input);
	
	
	#print "$input\n\n";
	

	foreach $part (@parts)
    {
        my @pair = getPairOfObject($part);   #This maybe should return the key with double quotes as a string.
        my $key = $pair[0];
        my $value = $pair[1];

	
        if (isNull($key)==0)
        {
            if (isNull($value)==1)
            {
				$dictionary{$key} = "";
            }
            elsif (isString($value)==1 || isBoolean($value)==1)
            {
				#print "string/bool expected:$value\n";
				$dictionary{$key} = $value;
            }
            elsif (isArray($value)==1)
            {  
				#print "***yes this is array!***\n";
				#print "Array expected:$value";
                my @elements = getArrayParts($value);
                my @parsedElements;

                foreach $element (@elements)
                {
                    if (isNull($element)==1 || isString($element)==1 || isBoolean($element)==1)
                    {	
                        push(@parsedElements,$element);
                    }
                    elsif (isArray($element)==1)
                    {
                        push(@parsedElements,Parse($element));
                    }
                    elsif (isObject($element)==1)
                    {
						my %parsedObj = Parse($element);
                        push(@parsedElements,(%parsedObj) );
                    }
					else
					{
						#print "maybe number:$element";
						push(@parsedElements,$element);
					}
                }
					
                $dictionary{$key} = [@parsedElements];
				
            }
            elsif (isObject($value)==1)
            {
				#print "object expected:$value";
				my %parsedObject = Parse($value);  
                $dictionary{$key} = (%parsedObject);   #%object = (%dictionary); 

				#my %retrievedObject = $parsedObject; #$dictionary{$key}; 

				#print "Retrived Oject:";
				#print Dumper(%retrievedObject);

		

				#print Dumper(\$dictionary{$key});
            }
            else
            {
				#print "number expected:$value";
				$dictionary{$key} = $value;
                #@_pair = split($value, ",\"");
                #my $_value = $_pair[0];
                #my $_element = $_pair[1];
                #dictionary{key} = $_value;
                #Parse($_element);
            }

        }
    }

	%object = (%dictionary); 
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
	my @inputArray = split //, $input;
	
    for (my $i=0;$i< @inputArray;$i++)
    {
        $ch = $inputArray[$i];
		
        if(index($ch,"{")==0)
		{
			$openedTag = $openedTag + 1;
		}
		elsif(index($ch,"}")==0)
        {
            $openedTag = $openedTag - 1;
        }
		elsif(index($ch,"[")==0)
        {
            $openedArray = $openedArray+1;
        }
		elsif(index($ch,"]")==0)
		{
            $openedArray = $openedArray-1;
        }
		elsif(index($ch,"\"")==0)
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
		elsif(index($ch,",")==0)
		{
            if ($openedString == 0 && $openedArray==0 && $openedTag == 1)
            {
				push @indexes,$i;
            }
            else
            {
                next;
            }
        }
	}
	
	
    my @parts =   split1($input, @indexes);
	
    return @parts;
}

sub getArrayParts
{
	my $input = $_[0];
    my @indexes;   # = new List<int>();
	
	my $openedArray = 1;  #'['
	my $openedObject = 0; #'{'
    my $openedString = 0; #'"'
    
	

    $input = removeTags($input);
	
	my @inputArray = split //, $input;
	

    for (my $i=0;$i< @inputArray;$i++)
    {
        $ch = $inputArray[$i];
		
        if(index($ch,"{")==0)
		{
			$openedObject = $openedObject + 1;
		}
		elsif(index($ch,"}")==0)
        {
            $openedObject = $openedObject - 1;
        }
		elsif(index($ch,"[")==0)
        {
            $openedArray = $openedArray+1;
        }
		elsif(index($ch,"]")==0)
		{
            $openedArray = $openedArray-1;
        }
		elsif(index($ch,"\"")==0)
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
		elsif(index($ch,",")==0)
		{
            if ($openedString == 0 && $openedArray==1 && $openedObject == 0)
            {
				push @indexes,$i;
            }
            else
            {
                next;
            }
        }
	}
	
	
    my @parts = split1($input, @indexes);
		
    return @parts;
}

#static String removeTags(String input)
sub removeTags
{
	my $input = $_[0];
    my $result = substr $input,1,(length $input)-2;    # input.Substring(1);
                                                       #result = result.Substring(0, result.Length - 1);
    return $result;
}

#static List<String> split1(String input,List<int> indexes)
sub split1
{
	($input,@indexes) = @_;
    my @parts;
    my $part;

    for (my $i = 0; $i < @indexes ; $i++)
    {
        #[3,8]
        $part = "";

		if ($i == 0 )
        {
            $part = substr $input,0,$indexes[$i];       # input.Substring(0, indexes[i]);
            #$input = substr $input,$indexes[$i]+1,(length $input) -1;       # input.Substring(indexes[i] + 1);
			
        }
        else
        {   
			#[5,10,15]  asdfghjkl
            #$part = substr $input,0,$indexes[$i] - $indexes[$i - 1] - 1;      #input.Substring(0, indexes[i] - indexes[i - 1] - 1);
            #$input = substr $input,$indexes[$i] - $indexes[$i - 1],(length $input) -  $indexes[$i];    #input.Substring(indexes[i] - indexes[i - 1] );
			#$input = substr $input,$indexes[$i]+1,(length $input) -1; 
			$part = substr $input,$indexes[$i-1]+1,$indexes[$i] - $indexes[$i - 1] - 1;      #input.Substring(0, indexes[i] - indexes[i - 1] - 1);
        }
		
		push @parts,$part;
    }

	my $a=length $input;
    my $indexesCount = @indexes;

    if($indexesCount != 0)
    {
        $part = substr $input,$indexes[$i -1]+1, $a - $indexes[$i -1]-1;
    }
    else
    {
        $part = $input;
    }

	push @parts,$part;
	#print Dumper(\@parts);
    return @parts;
}

#static List<String> split2(String input, String separator)
sub split2
{
    #{123:5}
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
    #{123:5}
    my $index = index($input,$separator,0);   # input.IndexOf(separator);  //4
    my $key = substr $input,1,$index -1;  #input.Substring(1, index - 1);
	my $value = substr $input,$index+1,(length $input)-$index-2;     # input.Substring(index + 1, input.Length - index - 2);
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

	if($input eq "" || $input eq "null")
	{
		return 1;
	}
	else
	{
		return 0;
	}
}
    

#static Boolean isString(String input)
sub isString
{
	my $input = $_[0];
	@array = split // , $input;
	if(($array[0] eq '"') && ($array[@array - 1] eq '"'))
	{
		return 1;
	}
	else
	{
		return 0;
	}   
	
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
	if($input eq "true" || $input eq "false")
	{
		return 1;
	}
	else
	{
		return 0;
	}

}

#static Boolean isObject(String input)
sub isObject
{
	my $input = $_[0];
	@array = split // , $input;
	
	if (($array[0] eq '{') && ($array[@array - 1] eq '}'))
	{
		return 1;
	}
	else
	{
		return 0;
	}
	
}

#static Boolean isArray(String input)
sub isArray
{
	my $input = $_[0];
	@array = split // , $input;
    
	if ($array[0] eq '[' && $array[@array - 1] eq ']')
	{
		return 1;
	}
	else	
	{
		return 0;
	}
}

#static List<String> getPairOfObject(String input)
sub getPairOfObject
{
	my $input = $_[0];
	#print "$input";
    #{123:5}
    my $index = index($input,':',0);
    my $key = substr $input,1,$index - 2;
    my $value = substr $input,$index + 1, (length $input)-$index;

	#print "key=$key\nval=$value\n\n";
	my @pair;
	push @pair,$key;
	push @pair,$value;

	#print Dumper(@pair);
    return @pair;
}

#static List<String> getElementsOfArray(String input)
sub getElementsOfArray
{
	$input = $_[0];
	
    #[123,5]
    #my @elements = split /[,\[\]]/, $input;
	my @elements = split //, $input;
	
	print "AAA:";
	#print Dumper \@elements;
	print $input;
	
	
    return \@elements;
}

#################################################################################################

