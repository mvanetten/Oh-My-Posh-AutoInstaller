# Get-Date cmdlets
Get-Date
# 31 October 2022 16:43:35

# cmdlets with named parameter
Get-Date -Day 5
# 5 October 2022 16:43:35

# cmdlets with named parameter
Get-Date -Year 2023
# 31 October 2023 16:43:35

# cmdlets Format Date

# dddd	Day of the week - full name
# MM	Month number
# dd	Day of the month - 2 digits
# yyyy	Year in 4-digit format
# HH:mm	Time in 24-hour format - no seconds
# K	Time zone offset from Universal Time Coordinate (UTC)

Get-Date -Format "dddd MM/dd/yyyy HH:mm K"

# output in variable
$currentdate = Get-Date
$currentdate.Year
# 2022s