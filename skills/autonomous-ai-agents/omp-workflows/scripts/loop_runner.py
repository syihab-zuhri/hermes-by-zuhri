#!/usr/bin/env python3
"""
Autonomous Loop Runner for Hermes (OMP Loop Adapter)
Executes a target command and reports structured evaluation.
Usage:
    python3 loop_runner.py --cmd "pytest" --until
"""

import argparse
import subprocess
import sys
import json
import time

def run_command(cmd, timeout=60):
    start = time.time()
    try:
        proc = subprocess.run(
            cmd,
            shell=True,
            capture_output=True,
            text=True,
            timeout=timeout
        )
        duration = round(time.time() - start, 2)
        return {
            "exit_code": proc.returncode,
            "stdout": proc.stdout[-2000:],
            "stderr": proc.stderr[-2000:],
            "duration_s": duration,
            "success": proc.returncode == 0
        }
    except subprocess.TimeoutExpired as e:
        duration = round(time.time() - start, 2)
        return {
            "exit_code": -1,
            "stdout": (e.stdout or "")[-1000:],
            "stderr": f"Command timed out after {timeout} seconds",
            "duration_s": duration,
            "success": False
        }

def main():
    parser = argparse.ArgumentParser(description="OMP Loop Runner")
    parser.add_argument("--cmd", required=True, help="Shell command to test")
    parser.add_argument("--timeout", type=int, default=60, help="Per-run timeout in seconds")
    parser.add_argument("--json", action="store_true", help="Output result as JSON")
    args = parser.parse_args()

    result = run_command(args.cmd, timeout=args.timeout)
    
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        status_tag = "PASS" if result["success"] else "FAIL"
        print(f"[{status_tag}] Exit Code: {result['exit_code']} (took {result['duration_s']}s)")
        if result["stdout"]:
            print("--- STDOUT (tail) ---")
            print(result["stdout"].strip())
        if result["stderr"]:
            print("--- STDERR (tail) ---")
            print(result["stderr"].strip())
            
    sys.exit(result["exit_code"])

if __name__ == "__main__":
    main()
