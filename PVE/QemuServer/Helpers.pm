package PVE::QemuServer::Helpers;

use strict;
use warnings;

use File::stat;

use PVE::INotify;
use PVE::ProcFSTools;

my $nodename = PVE::INotify::nodename();

# Paths and directories

our $var_run_tmpdir = "/var/run/qemu-server";
mkdir $var_run_tmpdir;

sub qmp_socket {
    my ($vmid, $qga) = @_;
    my $sockettype = $qga ? 'qga' : 'qmp';
    return "${var_run_tmpdir}/$vmid.$sockettype";
}

sub pidfile_name {
    my ($vmid) = @_;
    return "${var_run_tmpdir}/$vmid.pid";
}

sub vnc_socket {
    my ($vmid) = @_;
    return "${var_run_tmpdir}/$vmid.vnc";
}

# Parse the cmdline of a running kvm/qemu process and return arguments as hash
sub parse_cmdline {
    my ($pid) = @_;

    my $fh = IO::File->new("/proc/$pid/cmdline", "r");
    if (defined($fh)) {
	my $line = <$fh>;
	$fh->close;
	return undef if !$line;
	my @param = split(/\0/, $line);

	my $cmd = $param[0];
	return if !$cmd || ($cmd !~ m|kvm$| && $cmd !~ m@(?:^|/)qemu-system-[^/]+$@);

	my $phash = {};
	my $pending_cmd;
	for (my $i = 0; $i < scalar (@param); $i++) {
	    my $p = $param[$i];
	    next if !$p;

	    if ($p =~ m/^--?(.*)$/) {
		if ($pending_cmd) {
		    $phash->{$pending_cmd} = {};
		}
		$pending_cmd = $1;
	    } elsif ($pending_cmd) {
		$phash->{$pending_cmd} = { value => $p };
		$pending_cmd = undef;
	    }
	}

	return $phash;
    }
    return undef;
}

sub vm_running_locally {
    my ($vmid) = @_;

    my $pidfile = pidfile_name($vmid);

    if (my $fd = IO::File->new("<$pidfile")) {
	my $st = stat($fd);
	my $line = <$fd>;
	close($fd);

	my $mtime = $st->mtime;
	if ($mtime > time()) {
	    warn "file '$pidfile' modified in future\n";
	}

	if ($line =~ m/^(\d+)$/) {
	    my $pid = $1;
	    my $cmdline = parse_cmdline($pid);
	    if ($cmdline && defined($cmdline->{pidfile}) && $cmdline->{pidfile}->{value}
		&& $cmdline->{pidfile}->{value} eq $pidfile) {
		if (my $pinfo = PVE::ProcFSTools::check_process_running($pid)) {
		    return $pid;
		}
	    }
	}
    }

    return undef;
}

1;
