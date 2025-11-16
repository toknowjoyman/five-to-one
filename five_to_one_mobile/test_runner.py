#!/usr/bin/env python3
"""
Test runner that summarizes failures for easy debugging.
Usage: python3 test_runner.py [test_file]
"""

import subprocess
import sys
import re

def run_tests(test_file=None):
    """Run flutter tests and capture output."""
    cmd = ['flutter', 'test']
    if test_file:
        cmd.append(test_file)

    print("🧪 Running tests...")
    print("=" * 60)
    print()

    # Run the tests
    result = subprocess.run(cmd, capture_output=True, text=True)

    # Print full output
    print(result.stdout)
    if result.stderr:
        print(result.stderr)

    print()
    print("=" * 60)
    print("📋 FAILURE SUMMARY")
    print("=" * 60)
    print()

    if result.returncode != 0:
        print("❌ Tests failed. Copy the section below:\n")
        print("--- START COPY HERE ---\n")

        # Extract failures
        output = result.stdout + result.stderr

        # Find failed tests
        failed_tests = []
        lines = output.split('\n')

        for i, line in enumerate(lines):
            if 'FAILED' in line or 'Error:' in line or '✗' in line:
                # Get context (5 lines before and 10 lines after)
                start = max(0, i - 5)
                end = min(len(lines), i + 15)
                context = '\n'.join(lines[start:end])
                failed_tests.append(context)

        if failed_tests:
            print('\n\n'.join(failed_tests))
        else:
            # If no specific failures found, print last 50 lines
            print('\n'.join(lines[-50:]))

        print("\n--- END COPY HERE ---\n")

        # Count failures
        failure_count = output.count('FAILED')
        if failure_count > 0:
            print(f"Total failures: {failure_count}")
    else:
        print("✅ All tests passed!")

    return result.returncode

if __name__ == '__main__':
    test_file = sys.argv[1] if len(sys.argv) > 1 else None
    exit_code = run_tests(test_file)
    sys.exit(exit_code)
