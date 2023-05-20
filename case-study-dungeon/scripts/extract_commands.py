import glob, os, re, datetime, json, zipfile
import dateutil.parser, time

command_dispatched_pattern = re.compile(r"\s*Key: type\s*Value: CommandDispatched")
timestamp_pattern = re.compile(r"\s*Key: timestamp\s*Value: (.*Z)")
event_payload_pattern = re.compile(r"(\{.*\})", re.S)
csv_content = "timestamp,command_type\n"

for file in glob.glob("logs-*.zip"):
    with zipfile.ZipFile(file, "r") as zip_ref:
        with zip_ref.open("results/logs/kaf-command.txt") as kafka_log:
            kafka_log = kafka_log.read().decode("utf-8")
            events = kafka_log.split("Headers:")
            commands_dispatched = [event for event in events if command_dispatched_pattern.search(event)]
            for event in commands_dispatched:
                event_payload = json.loads(event_payload_pattern.search(event).group(1))
                timestamp = dateutil.parser.isoparse(timestamp_pattern.search(event).group(1))
                command_type = event_payload["commandType"]
                csv_content += f"{int(timestamp.timestamp())},{command_type}\n"

f = open("results/case-study-dungeon/commands.csv", "w")
f.write(csv_content)
f.close()