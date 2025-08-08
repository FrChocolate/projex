import subprocess
import toml

print("Upgrading versions")
with open("pyproject.toml", "r", encoding="utf-8") as fp:
    data = toml.load(fp)

version = data["project"]["version"]
version = version.split(".")
version[-1] = str(int(version[-1]) + 1)
version = ".".join(version)
data["project"]["version"] = version

with open("pyproject.toml", "+w") as fp:
    toml.dump(data, fp)

print("All versions now are on", version)
