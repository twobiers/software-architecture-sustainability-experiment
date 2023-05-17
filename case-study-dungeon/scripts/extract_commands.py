import glob, os, re, datetime, json, zipfile
import dateutil.parser, time

revealed_pattern = re.compile(r"\s*Key: type\s*Value: CommandDispatched")
csv_content = "command_dispatched_count\n"

for file in glob.glob("logs-*.zip"):
    with zipfile.ZipFile(file, "r") as zip_ref:
        with zip_ref.open("results/logs/kaf-command.txt") as kafka_log:
            kafka_log = kafka_log.read().decode("utf-8")
            events = kafka_log.split("Headers:")
            commands_dispatched = [event for event in events if revealed_pattern.search(event)]
            csv_content += f"{len(commands_dispatched)}\n"

f = open("results/case-study-dungeon/commands.csv", "w")
f.write(csv_content)
f.close()