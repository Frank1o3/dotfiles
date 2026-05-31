#!/usr/bin/env python3
"""
Roblox FFlag Search Tool (Dynamic Multi-Source)
Searches any number of Roblox FFlag JSON files for flags matching a prefix, substring, or regex.

Usage:
    python fflag_search.py <query> [--output results.txt] [--mode prefix|contains|regex]
                               [--ignore-case] [--verbose] [--json-output]

Examples:
    python fflag_search.py FFlagDebug
    python fflag_search.py vulkan --mode contains -i
    python fflag_search.py "Render|Physics" --mode regex -o graphics.txt
"""

import json
import argparse
import requests
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Callable

# =============================================================================
# 📦 CONFIGURATION: Add/remove sources here - everything else auto-adapts!
# =============================================================================
SOURCES = {
    # Desktop Clients
    "PCDesktopClient.json": "https://raw.githubusercontent.com/MaximumADHD/Roblox-FFlag-Tracker/refs/heads/main/PCDesktopClient.json",
    "MacDesktopClient.json": "https://raw.githubusercontent.com/MaximumADHD/Roblox-FFlag-Tracker/refs/heads/main/MacDesktopClient.json",
    "AndroidApp.json": "https://raw.githubusercontent.com/MaximumADHD/Roblox-FFlag-Tracker/refs/heads/main/AndroidApp.json"
}
# =============================================================================


def fetch_json(url: str, timeout: int = 30) -> dict:
    """Fetch and parse JSON from URL"""
    print(f"📡 Fetching {url}...", file=sys.stderr)
    response = requests.get(url, timeout=timeout)
    response.raise_for_status()
    return response.json()


def make_filter(query: str, mode: str, ignore_case: bool) -> Callable[[str], bool]:
    """
    Create a filter function based on search mode.

    Modes:
      - 'prefix': flag name starts with query
      - 'contains': query appears anywhere in flag name
      - 'regex': query is a regex pattern
    """
    if ignore_case:
        query = query.lower()

    if mode == "prefix":

        def filter_func(name: str) -> bool:
            check_name = name.lower() if ignore_case else name
            return check_name.startswith(query)

        return filter_func

    elif mode == "contains":

        def filter_func(name: str) -> bool:
            check_name = name.lower() if ignore_case else name
            return query in check_name

        return filter_func

    elif mode == "regex":
        flags = re.IGNORECASE if ignore_case else 0
        try:
            pattern = re.compile(query, flags)
        except re.error as e:
            print(f"❌ Invalid regex pattern: {e}", file=sys.stderr)
            sys.exit(1)

        def filter_func(name: str) -> bool:
            return bool(pattern.search(name))

        return filter_func

    else:
        raise ValueError(f"Unknown mode: {mode}")


def filter_flags(
    data: dict, filter_func: Callable[[str], bool]
) -> List[Tuple[str, any]]:
    """Filter flags using the provided filter function"""
    matches = []
    for name, value in data.items():
        if filter_func(name):
            matches.append((name, value))
    return sorted(matches, key=lambda x: x[0])


def format_value_for_output(value: any) -> str:
    """Format a flag value for config-style output"""
    if isinstance(value, bool):
        return str(value).lower()  # true/false for Roblox config
    elif isinstance(value, str):
        return f'"{value}"'
    else:
        return str(value)


def format_output(
    results: Dict[str, List[Tuple[str, any]]],
    query: str,
    mode: str,
    source_order: List[str],
) -> str:
    """Format results in the requested output style - DYNAMIC: uses source_order list"""
    lines = [
        "# Roblox FFlag Search Results",
        f"# Query: '{query}' (mode: {mode})",
        f"# Files searched: {', '.join(source_order)}",
        "",
    ]

    # Dynamically iterate over provided source order
    for filename in source_order:
        lines.append(f"# {filename}")
        matches = results.get(filename, [])

        if matches:
            for flag_name, flag_value in matches:
                formatted_value = format_value_for_output(flag_value)
                lines.append(f"{flag_name}={formatted_value}")
        else:
            lines.append("# (no matches)")
        lines.append("")  # Blank line between sections

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(
        description="Search Roblox FFlags across multiple platform files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=f"""
Available Sources ({len(SOURCES)} configured):
  {chr(10).join(f"  • {name}" for name in SOURCES.keys())}

Search Modes:
  prefix    - Match flags that START with the query (default)
  contains  - Match flags that CONTAIN the query anywhere
  regex     - Treat query as a regular expression pattern

Examples:
  # Search all configured sources for Vulkan flags
  %(prog)s vulkan --mode contains -i

  # Search only Android flags (for Sober/Linux users)
  %(prog)s render --mode contains -i --sources AndroidApp.json

  # Export matching flags as JSON for ClientSettings
  %(prog)s FBoolEnable --mode prefix -j -o enabled_flags.json
        """,
    )
    parser.add_argument(
        "query", help="Search query (prefix, substring, or regex pattern)"
    )
    parser.add_argument(
        "-m",
        "--mode",
        choices=["prefix", "contains", "regex"],
        default="prefix",
        help="Search mode: prefix (default), contains, or regex",
    )
    parser.add_argument(
        "-o",
        "--output",
        default="fflag_results.txt",
        help="Output file path (default: fflag_results.txt)",
    )
    parser.add_argument(
        "-i",
        "--ignore-case",
        action="store_true",
        help="Perform case-insensitive search",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="Show detailed progress information",
    )
    parser.add_argument(
        "-j",
        "--json-output",
        action="store_true",
        help="Output results as JSON instead of config format",
    )
    parser.add_argument(
        "-s",
        "--sources",
        nargs="+",
        help=f"Limit search to specific source files. Options: {', '.join(SOURCES.keys())}",
    )

    args = parser.parse_args()

    # Determine which sources to use
    if args.sources:
        # Validate requested sources exist
        invalid = set(args.sources) - set(SOURCES.keys())
        if invalid:
            print(f"❌ Unknown source(s): {', '.join(invalid)}", file=sys.stderr)
            print(f"💡 Available: {', '.join(SOURCES.keys())}", file=sys.stderr)
            sys.exit(1)
        # Preserve order of requested sources
        source_order = [s for s in args.sources if s in SOURCES]
    else:
        # Use all sources in configured order (Python 3.7+ dict order preserved)
        source_order = list(SOURCES.keys())

    results = {}
    total_found = 0

    try:
        # Create filter function based on mode
        filter_func = make_filter(args.query, args.mode, args.ignore_case)

        for filename in source_order:
            url = SOURCES[filename]
            if args.verbose:
                print(f"🔍 Processing {filename}...", file=sys.stderr)

            # Fetch and parse
            data = fetch_json(url)

            # Filter flags
            matches = filter_flags(data, filter_func)
            results[filename] = matches

            count = len(matches)
            total_found += count
            if args.verbose:
                print(
                    f"   ✓ Found {count} matching flag(s) in {filename}",
                    file=sys.stderr,
                )

        # Format output
        if args.json_output:
            # Convert to flat JSON structure (later sources override earlier on duplicate names)
            json_output = {}
            for filename in source_order:
                for name, value in results.get(filename, []):
                    json_output[name] = value
            output_content = json.dumps(json_output, indent=2, sort_keys=True)
        else:
            output_content = format_output(results, args.query, args.mode, source_order)

        # Write to file
        output_path = Path(args.output)
        output_path.write_text(output_content, encoding="utf-8")

        # Summary to console
        print("\n✅ Search complete!")
        print(
            f"📊 Found {total_found} total flag(s) matching '{args.query}' (mode: {args.mode})"
        )
        print(f"📁 Sources searched: {len(source_order)}")
        print(f"💾 Results saved to: {output_path.resolve()}")

        # Preview first few results (dynamic)
        if total_found > 0 and args.verbose:
            print("\n🔎 Preview (first 6 matches):")
            preview_count = 0
            for filename in source_order:
                for name, value in results.get(filename, [])[:3]:
                    print(f"   [{filename}] {name} = {format_value_for_output(value)}")
                    preview_count += 1
                    if preview_count >= 6:
                        break
                if preview_count >= 6:
                    break

    except requests.RequestException as e:
        print(f"❌ Network error: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"❌ JSON parse error: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
