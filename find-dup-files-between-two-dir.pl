#!/usr/bin/perl

# README
# 
# Checks a folder for Albums that are similar 
# eg : 
# Arist-Back_In_Black-(Remastered)-2001-XXX
# Artist-Back_In_Black-(Reissue)-2000-YYY
#
# Script prompts you for which one to "zz" (putting zz in front of the file name you can delete it later)
#
# CONFIG
# 
# Put your mp3 directory path in the $mp3dirpath variable
#

$mp3dirpath = '/data/downloads/MP3';

# END CONFIG


@txt= qx{ls $mp3dirpath};


sort (@txt);

$re1='.*?'; 
$re2='(?:[a-z][a-z0-9_]*)';
$re3='.*?';
$re4='((?:[a-z][a-z0-9_]*))';

$re=$re1.$re2.$re3.$re4;

$foreach_count_before=0; #Setups up counter
$foreach_count_after=1; #Setups up counter


$number_in_arry = scalar (@txt);

while ($foreach_count_before < $number_in_arry) {
                                        if ($txt[$foreach_count_before] =~ m/$re/is)
                                            { 
                                             $var1=$1;
                                             }
                                         if ($txt[$foreach_count_after] =~ m/$re/is)
                                            { 
                                             $var2=$1;
                                             }
                                         if ($var1 eq $var2)
                                            {
                                             print "-------------------------------------\n";
                                             print "$txt[$foreach_count_before] \n";
                                             print "MATCHES \n";
                                             print "\n$txt[$foreach_count_after] \n";
                                             print "Which Should I Remove? \n";
                                             print "[1] $txt[$foreach_count_before]\n";
                                             print "[2] $txt[$foreach_count_after]\n";
                                             print "[Any Other Key] Take No Action\n\n";

                                             $answer = <>;        # Get user input, assign it to the variable 
                                                if    ( $answer == "1" ) { 
                                                      print "ZZing $txt[$foreach_count_before]";
                                                      $originalfilename = $mp3dirpath . '/' . $txt[$foreach_count_before];
                                                      $newfilename = $mp3dirpath . '/' . 'zz' . $txt[$foreach_count_before];
                                                      $originalfilename = trim($originalfilename);
                                                      $newfilename = trim($newfilename);
                                                      qx(mv $originalfilename $newfilename);
                                                } 
                                                elsif ( $answer == "2" ) { 
                                                      print "ZZing $txt[$foreach_count_after]";
                                                      $originalfilename = $mp3dirpath . '/' . $txt[$foreach_count_after];
                                                      $newfilename = $mp3dirpath . '/' . 'zz' . $txt[$foreach_count_after];
                                                      $originalfilename = trim($originalfilename);
                                                      $newfilename = trim($newfilename);
                                                      print "mv $originalfilename $newfilename";
                                                      qx(mv $originalfilename $newfilename);
                                                } 
                                                else { 
                                                      print "Taking No Action"; 
                                                }

                                            }

                                           $foreach_count_before++;
                                           $foreach_count_after++;

                                        }

# SubRoutine For Trimming White Space from variables
sub trim($)
{
 my $string = shift;
 $string =~ s/^\s+//;
 $string =~ s/\s+$//;
 return $string;
