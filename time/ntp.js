<!DOCTYPE html>
<html>
<body>

<h2>Demo JavaScript in Body</h2>

<p id="demo">A Paragraph.</p>

<button type="button" onclick="myFunction()">Try it</button>
<script>
// Prompting for user input
var T1 = parseFloat(prompt("Enter value for T1:"));
var T2 = parseFloat(prompt("Enter value for T2:"));
var T3 = parseFloat(prompt("Enter value for T3:"));
var T4 = parseFloat(prompt("Enter value for T4:"));

// Calculating NTP Server Round Trip Delay
var roundTripDelay = (T4 - T1) - (T3 - T2);

// Calculating NTP Server Clock Offset
var clockOffset = ((T2 - T1) + (T3 - T4)) / 2;

// Presenting the results
console.log("NTP Server Round Trip Delay:", roundTripDelay);
console.log("NTP Server Clock Offset:", clockOffset);
</script>

</body>
</html> 

