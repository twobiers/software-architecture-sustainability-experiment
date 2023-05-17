import glob, os, re, datetime, json, zipfile
import dateutil.parser, time

revealed_pattern = re.compile(r"\s*Key: type\s*Value: RobotsRevealedIntegrationEvent")
timestamp_pattern = re.compile(r"\s*Key: timestamp\s*Value: (.*Z)")
event_payload_pattern = re.compile(r"(\{.*\})", re.S)
csv_content = "timestamp,robot_count\n"

for file in glob.glob("logs-*.zip"):
    with zipfile.ZipFile(file, "r") as zip_ref:
        with zip_ref.open("results/logs/kaf-robot.integration.txt") as kafka_log:
            kafka_log = kafka_log.read().decode("utf-8")
            events = kafka_log.split("Headers:")
            revealed_events = [event for event in events if revealed_pattern.search(event)]
            for event in revealed_events:
                timestamp = dateutil.parser.isoparse(timestamp_pattern.search(event).group(1))
                robot_count = len(json.loads(event_payload_pattern.search(event).group(1))["robots"])
                csv_content += f"{int(timestamp.timestamp())},{robot_count}\n"

f = open("results/case-study-dungeon/robots.csv", "w")
f.write(csv_content)
f.close()