#################### Computer Networks ###################
#################### Lab Assignment_ 1 ###################
##################### Submitted by, ######################
############## Devanshi Piprottar_ (131011) ##############
######### Institute of Engineering and Technology ########

# Lan simulation

set ns [new Simulator]

# Define colors for data flows

$ns color 1 Blue
$ns color 2 Red
$ns color 3 Yellow

# Open trace files

set tracefile1 [open out.tr w]
set winfile [ open winfile w ]
$ns trace-all $tracefile1

# Open nam file

set namfile [ open out.nam w ]
$ns namtrace-all $namfile

# Define "finish" method to terminate the program

proc finish {} \
{
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

# Create wireless nodes.

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]


# Create links between nodes.

$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n4 $n5 2Mb 30ms DropTail
$ns duplex-link $n4 $n6 2Mb 30ms DropTail
$ns duplex-link $n5 $n6 2Mb 33ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail

# Give node position

$ns duplex-link-op $n3 $n2 orient left-down
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n0 $n1 orient left-down
$ns duplex-link-op $n1 $n2 orient right-down
$ns duplex-link-op $n4 $n5 orient right-up
$ns duplex-link-op $n4 $n6 orient right-down
$ns duplex-link-op $n5 $n6 orient down
$ns duplex-link-op $n6 $n7 orient left-down
$ns duplex-link-op $n6 $n8 orient right-down
$ns duplex-link-op $n9 $n10 orient right-down

# Set lan between n2, n4 and n9 nodes

set lan [ $ns newLan " $n2 $n9 $n4 " 0.3Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel ]

# Set up a TCP connection

set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 1000

# Set up a ftp over tcp connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp

# Set up a UDP connection

set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp $null
$udp set fid_ 2

# Set up a cbr over udp connection

set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 0.01Mb
$cbr set random_ false

# Set up a UDP connection

set udp_1 [new Agent/UDP]
$ns attach-agent $n8 $udp_1
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp_1 $null
$udp set fid_ 3

# Set up a cbr over udp connection

set cbr_1 [new Application/Traffic/CBR]
$cbr_1 attach-agent $udp_1
$cbr_1 set type_ CBR
$cbr_1 set packet_size_ 1000
$cbr_1 set rate_ 0.01Mb
$cbr_1 set random_ false

# Scheduling the events

$ns at 0.1 "$cbr_1 start"
$ns at 1.0 "$cbr start"
$ns at 2.0 "$ftp start"
$ns at 123.0 "$ftp stop"
$ns at 124.0 "$cbr stop"
$ns at 125.5 "$cbr_1 stop"

# Define plotWindow method 

proc plotWindow {tcpSource file} \
{
global ns
set time 0.1 
set now [$ns now]
set cwnd1 [$tcpSource set cwnd_]
puts $file "$now $cwnd1"
$ns at [ expr $now+$time ] "plotWindow $tcpSource $file"
}

# Call plotWindow and finish method 

$ns at 0.1 " plotWindow $tcp $winfile "

# Termination of the program

$ns at 125.0 "finish"
$ns run
