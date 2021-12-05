# Mining Routine
Hello, this is the mining routine script. It allows you to run your mining software only during the provided schedule. This is useful especially if your energy provider offers different prices for energy during different times of the day. If you want to mine and you are concearned with the amount of money you spend mining and the impact on the environment than this can be a helpful script.


# Compatibility
This is a **powershell** script. It was developed using powershell core 7.2.0. But it also works on powershell 5.1.

# Pre-Requisites

The mining software used in the examples is lolminer. The script is done in a way that you can provide other mining softwares and arguments. However the tests were only performed using lolminer.
The used software can be downloaded from https://github.com/Lolliedieb/lolMiner-releases/releases

# Roadmap

Further improvements for the script:

 - Flag to enable/disable computer sleep;
 -  Wake computer from sleep using  schedule tasks;
 - Make script compatible with Linux

# Parameters
The following parameters are mandatory:

|                |Description                         |Example                                                                |
|----------------|----------------------------------- |-----------------------------------------------------------------------| 
|processName     | The name of the mining exe process |lolminer                                                               |
|ScheduleJson    | Path to the Schedule Json file     | C:\temp\MiningRoutine\OffpeakSchedule\PT\GoldEnergy.json              |
|executablePath  | Path to the executable file        | C:\Program Files\lolMiner_v1.36a_Win64\1.36a\lolMiner.exe             |
|executableArgs  | Arguments for the mining software  | --algo ETHASH --pool eth.2miners.com:2020 --user "yourwallet address" |


# Examples

Open a powershell window and use Set-Location to define the script location.
Then execute the commands bellow
```

MiningRoutine.ps1 -processName "lolminer" -ScheduleJson "C:\temp\MiningRoutine\OffpeakSchedule\PT\GoldEnergy.json" `
-executablePath "C:\Program Files\lolMiner_v1.36a_Win64\1.36a\lolMiner.exe" `
-executableArgs --algo ETHASH --pool eth.2miners.com:2020 --user "0xBgbyo0LiydQG5dlCQUWP0NNjbNzSCePLD8R8FYws"

```