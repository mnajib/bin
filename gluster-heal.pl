#!/usr/bin/perl -w
#
# Gluster Healing Tool
# This Tool runs on the Gluster CLIENT side

# @note there are a bunch of hard-coded things you should change

# Read All Log Files /var/log/glusterfs/glusterfs.log
#  On Error Trigger

use strict;
use warnings;
use Data::Dumper;
use Digest::MD5;
use File::Basename;

#
# Set Config Vars
my $gluster_logs = 'glusterfs.log'; # '/var/log/glusterfs/glusterfs.log';
my $gluster_root = "/gluster";
my $exec_on = 1;

# Internal Stuff
my $tail_pid;
my %volbrick;

$ENV{ 'PATH' } = '/bin:/usr/bin:/usr/local/bin';
delete @ENV{ 'IFS', 'CDPATH', 'ENV', 'BASH_ENV' };

# Signal Handlers
# $SIG{INT} = $SIG{TERM} = sub { 
#   print "INT/TERM $$\n";
#   kill $tail_pid;
#   exit(1);
# };
# 
# $SIG{CHLD} = sub {
#     wait;
# };
# 

sub find_stat($)
{
    # `mount $gluster_root`;
    # Just Run Find, Iterating Depth 1,2,3,4,5,6....
    # `umount $gluster_root`;

}

sub gluster_ctl($)
{
    my $a = shift;
    if ('start' eq $a) {
        _exec('echo "y" | ssh cluster1 "gluster volume start prod"');
        _exec('mount /glusterfs');
    } elsif ('stop' eq $a) {
        # print "umount & stop Prod Volume\n";
        _exec('umount /glusterfs');
        _exec('echo "y" | ssh cluster1 "gluster volume stop prod"');
    } else {
        die("Nope! $a\n");
    }
}

sub _exec($)
{
    my $cmd = shift;
    print "+$cmd\n";
    if ($exec_on) {
        print `$cmd`;
    }
}

sub ls_all($)
{
    my $p = shift;
    _exec("ssh cluster1 'ls -alh /data/gluster/prod/brick1" . $p . "'");
    _exec("ssh cluster1 'ls -alh /data/gluster/prod/brick2" . $p . "'");
    _exec("ssh cluster2 'ls -alh /data/gluster/prod/brick1" . $p . "'");
    _exec("ssh cluster2 'ls -alh /data/gluster/prod/brick2" . $p . "'");
    _exec("ssh cluster3 'ls -alh /data/gluster/prod/brick1" . $p . "'");
    _exec("ssh cluster3 'ls -alh /data/gluster/prod/brick2" . $p . "'");
}

#
# Pull from All 6 Locations to Here
#      Figuure out how to find zero files?
sub rsync_pull($)
{
    my $p = shift;
    _exec("rm -fr /tmp/a /tmp/b /tmp/c /tmp/d /tmp/e /tmp/f");
    _exec("rsync -a cluster1:/data/gluster/prod/brick1$p/ /tmp/a/");
    _exec("rsync -a cluster1:/data/gluster/prod/brick2$p/ /tmp/b/");
    _exec("rsync -a cluster2:/data/gluster/prod/brick1$p/ /tmp/c/");
    _exec("rsync -a cluster2:/data/gluster/prod/brick2$p/ /tmp/d/");
    _exec("rsync -a cluster3:/data/gluster/prod/brick1$p/ /tmp/e/");
    _exec("rsync -a cluster3:/data/gluster/prod/brick2$p/ /tmp/f/");
}

sub rsync_sort()
{
    `rm -fr /tmp/fix`;
    mkdir('/tmp/fix') or die("What? $!");

    open(my $ph0,'find /tmp/a /tmp/b /tmp/c /tmp/d /tmp/e /tmp/f -type f |cut -c8- |sort |uniq  |');
    while (my $file_find = <$ph0>) {

        chomp($file_find);

        my %size_stat;
        my %name_stat;

        # print "Checking: $n\n";

        open(my $ph1,"find /tmp/a /tmp/b /tmp/c /tmp/d /tmp/e /tmp/f -type f -name $file_find|");
        while (my $line = <$ph1>) {
            chomp($line);
            my $size = -s $line;
            if ($size > 0) {
                # print "File: $line is $size\n";
                $size_stat{"s$size"}++;
                $name_stat{"s$size"} = $line;
            } else {
                # print "File: $line is $size - Ignoring\n";
            }
        }
        my $file;
        my $vote = 0;
        my @keys = sort(keys(%size_stat));
        if (scalar(@keys) == 0) {
            print "File: $file_find has 0 candidates, lost\n";
        } elsif (scalar(@keys) == 1) {
            while (@keys) {
                my $k = pop(@keys);
                $vote = $size_stat{$k};
                $file = $name_stat{$k};
                print "File: $file_find ($file) has $vote votes\n";
            }
            if ($vote < 1) {
                die("Not Enough Votes: $vote\n");
            }
            `cp $file /tmp/fix/`;
        } else {
            die("Too many File Keys\n");
        }
    }
}


sub xattr_clear($)
{
    return;
    my $p = shift;
    _exec("ssh cluster1 '/opt/edoceo/gluster-xattr-clear.sh /data/gluster/prod/brick1" . dirname($p) . "'");
    _exec("ssh cluster1 '/opt/edoceo/gluster-xattr-clear.sh /data/gluster/prod/brick2" . dirname($p) . "'");
    _exec("ssh cluster2 '/opt/edoceo/gluster-xattr-clear.sh /data/gluster/prod/brick1" . dirname($p) . "'");
    _exec("ssh cluster2 '/opt/edoceo/gluster-xattr-clear.sh /data/gluster/prod/brick2" . dirname($p) . "'");
    _exec("ssh cluster3 '/opt/edoceo/gluster-xattr-clear.sh /data/gluster/prod/brick1" . dirname($p) . "'");
    _exec("ssh cluster3 '/opt/edoceo/gluster-xattr-clear.sh /data/gluster/prod/brick2" . dirname($p) . "'");
}

sub read_conf()
{
    my $v;
    my $b;

    open(my $fh,'/opt/edoceo/gluster.vol') or die("Couldn't read conf: $!\n");
    while (my $line = <$fh>) {
        # $volbrick{'volume'}{'brick1'};
        if ($line =~ m/\svolume (.+)$/o) {
            $v = $1;
            # print "Volume: $v\n";
            $volbrick{$v} = {};
        } elsif ($line =~ m/\soption remote\-host (.+)$/o) {
            $volbrick{$v}{'host'} = $1;
        } elsif ($line =~ m/\soption remote\-subvolume (.+)$/o) {
            $volbrick{$v}{'path'} = $1;
        } elsif ($line =~ m/\stype (.+)/o) {
            $volbrick{$v}{'type'} = $1;
        } elsif ($line =~ m/\ssubvolumes (.+)/o) {
            $volbrick{$v}{'pair'} = $1;
        }
    }
    my $list = keys(%volbrick);
    # foreach ( 
    # print "B: " . $volbrick{'prod-client-1'}{'host'} . ':' . $volbrick{'prod-client-1'}{'path'} . "\n";
    # print "R: " . $volbrick{'prod-replicate-0'}{'type'} . "\n";
    # print "R: " . $volbrick{'prod-replicate-0'}{'pair'} . "\n";

}

#
# This reads the log files watching for errors (~= m/ E /)
sub child_log_reader()
{
    # Track the last Path mentioned
    my ($cmd,$buf0,$buf1);
    my ($prev_p,$prev_v);

    open(my $ph,"tail -n2000 $gluster_logs|") or die("Couldn't start tail: $!\n");
    while (my $line = <$ph>) {
        chomp($line);
        if ($line =~ m/ \d\-([\w\-]+): path (.+) on subvolume (.+) => (.+)$/o) {

            my $p = $2; # Path
            my $b = $3; # Brick
            $prev_p = $p;
            $prev_v = $1;

            print "Volume $1 cannot find $p on Brick $b ($4)\n";

            # On Stripe it's lost
            if ('cluster/replicate' eq $volbrick{$1}{'type'}) {
                # Find the Mirror
                my $m = $volbrick{$1}{'pair'};
                print "  Host: $m\n";
                $m =~ s/$b//g;
                $m =~ s/\s+//g;

                # print "  Fail: $b " . $volbrick{$b}{'host'} . ':' . $volbrick{$b}{'path'} . "\n";
                # print "  Good: $m " . $volbrick{$m}{'host'} . ":" . $volbrick{$m}{'path'} . "\n";

                $cmd = 'ssh ' . $volbrick{$m}{'host'} . ' "rsync -av ' . $volbrick{$m}{'path'} . $p;
                $cmd.= ' ' . $volbrick{$b}{'host'} . ':' . $volbrick{$b}{'path'} . $p . '"';
                _exec($cmd);

                print "\n";

            }

        } elsif ($line =~ m/ \d\-([\w\-]+): remote operation failed: No such file or directory/o) {

            my $v = $1; # Volume
            my $p = $prev_p;

            print "Volume $prev_v::$v cannot find $p\n";
            if ('cluster/replicate' eq $volbrick{$prev_v}{'type'}) {
                print "Replica, Try Other Side\n";
            }

        } elsif ($line =~ m/ \d\-([\w\-]+): background\s+entry self\-heal failed on (.+)$/o) {

            my $v = $1; # Volume
            my $p = $2; # Path
            $prev_v = $v;
            $prev_p = $p;

            print "Volume $v Self Heal Falure $p\n";
            rsync_pull($p);
            rsync_sort();
            gluster_ctl('stop');
            _exec("ssh cluster1 'rm -fr /data/gluster/prod/brick1$p'");
            _exec("ssh cluster1 'rm -fr /data/gluster/prod/brick2$p'");
            _exec("ssh cluster2 'rm -fr /data/gluster/prod/brick1$p'");
            _exec("ssh cluster2 'rm -fr /data/gluster/prod/brick2$p'");
            _exec("ssh cluster3 'rm -fr /data/gluster/prod/brick1$p'");
            _exec("ssh cluster3 'rm -fr /data/gluster/prod/brick2$p'");
            gluster_ctl('start');
            _exec("rsync -av /tmp/fix/ /glusterfs$p/");
            exit;

            if ('cluster/replicate' eq $volbrick{$v}{'type'}) {

                # print "  Replica Volume!\n";
                my ($b0,$b1) = split(/ /,$volbrick{$v}{'pair'});

                $cmd = 'ssh ' . $volbrick{$b0}{'host'} . ' "ls -alh ' . $volbrick{$b0}{'path'} . $p . '" | tee /tmp/buf0';
                print "$cmd\n";
                $buf0 = `$cmd`;

                $cmd = 'ssh ' . $volbrick{$b1}{'host'} . ' "ls -alh ' . $volbrick{$b1}{'path'} . $p . '" | tee /tmp/buf1';
                print "$cmd\n";
                $buf1 = `$cmd`;


                if ($buf0 ne $buf1) {

                    # print `diff -y /tmp/buf0 /tmp/buf1`;

                    my $s0 = 0;
                    my $s1 = 0;
                    if ($buf0 =~ m/total (\d+)M/) { $s0 = $1; }
                    if ($buf1 =~ m/total (\d+)M/) { $s1 = $1; }
                    if ( ($s0 > 0) && ($s1 > 0) ) {
                        if ($s0 > $s1) {
                            $cmd = 'ssh ' . $volbrick{$b0}{'host'} . ' "rsync -av ' . $volbrick{$b0}{'path'} . $p . '/';
                            $cmd.= ' ' . $volbrick{$b1}{'host'} . ':' . $volbrick{$b1}{'path'} . $p . '/"';
                            _exec($cmd);
                        } elsif ($s1 > $s0) {
                            $cmd = 'ssh ' . $volbrick{$b1}{'host'} . ' "rsync -av ' . $volbrick{$b1}{'path'} . $p . '/';
                            $cmd.= ' ' . $volbrick{$b0}{'host'} . ':' . $volbrick{$b0}{'path'} . $p . '/"';
                            _exec($cmd);
                        }
                    } else {
                        die("Cannot Parse that size");
                    }
                    xattr_clear($p);

                }

                # These 2 blank xattrs
                # xattr_clear($p);

                # _exec("echo 'y' | ssh cluster1 'gluster volume start prod'");

            }

            # print "Directory Self Heal: $1\n";
            # print "  $line\n";

        } elsif ($line =~ m/ \d\-([\w\-]+): background\s+entry gfid self\-heal failed on (.+)/o) {

            my $v = $1;
            my $p = $2;

            print "Volume: $v GFID Failure $p\n";

            my ($b0,$b1) = split(/ /,$volbrick{$v}{'pair'});

            $cmd = "ssh " . $volbrick{$b0}{'host'} . " 'getfattr -m .  -d -e hex " . $volbrick{$b0}{'path'} . $p . " 2>/dev/null'";
            # _exec($cmd);

            $cmd = "ssh " . $volbrick{$b1}{'host'} . " 'getfattr -m .  -d -e hex " . $volbrick{$b1}{'path'} . $p . " 2>/dev/null'";
            # _exec($cmd);

            xattr_clear($p);

            # These Blank all xattrs
        } elsif ($line =~ m/ disk space on subvolume 'prod-replicate-2' is getting full (91.00 %), consider adding more nodes/o) {
            # @todo make an alert about how this is missign
        } elsif ($line =~ m/remote operation failed: Stale NFS file handle/o) {
            # Ignore
        } else {
            # 0-prod-client-0: remote operation failed: No such file or directory
            print "$line\n";
        }
    }

}

#
#
sub fork_logs_tail()
{
    $tail_pid = fork();
    if ($tail_pid == 0) {
        child_log_reader();
        exit(0);
    }
    waitpid($tail_pid,0);
    return 1;
}

#
# 
find_stat($gluster_root);

read_conf();

#
# Start the Log Monitor
# fork_logs_tail();
child_log_reader();

# find_stat($gluster_root);
