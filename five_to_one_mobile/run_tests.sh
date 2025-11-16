#!/bin/bash

# Test runner with failure summary
# Usage: ./run_tests.sh [test_file]

echo "🧪 Running tests..."
echo "===================="
echo ""

# Run tests and capture output
if [ -z "$1" ]; then
    # Run all tests
    flutter test 2>&1 | tee test_output.txt
else
    # Run specific test file
    flutter test "$1" 2>&1 | tee test_output.txt
fi

# Capture exit code
TEST_EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "===================="
echo "📋 FAILURE SUMMARY"
echo "===================="
echo ""

# Extract and display failures
if [ $TEST_EXIT_CODE -ne 0 ]; then
    echo "❌ Tests failed. Copy the section below to report issues:"
    echo ""
    echo "--- START COPY HERE ---"
    echo ""

    # Extract failure information
    grep -A 20 "FAILED" test_output.txt || grep -A 20 "Error:" test_output.txt || cat test_output.txt

    echo ""
    echo "--- END COPY HERE ---"
    echo ""
else
    echo "✅ All tests passed!"
fi

# Clean up
rm -f test_output.txt

exit $TEST_EXIT_CODE
