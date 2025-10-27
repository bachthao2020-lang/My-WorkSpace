#!/usr/bin/env python3
"""
MoonSec V3 Decryptor for Roblox Lua Scripts
This script attempts to decrypt MoonSec V3 obfuscated Lua code
"""

import re
import base64
import zlib

def extract_encoded_strings(content):
    """Extract encoded strings from the obfuscated content"""
    # Look for string patterns in the obfuscated code
    string_patterns = [
        r'h\(f\([0-9]+,"([^"]+)"\)\)',  # h(f(number,"string"))
        r'"([^"]{20,})"',  # Long quoted strings
        r"'([^']{20,})'",  # Long single-quoted strings
    ]
    
    strings = []
    for pattern in string_patterns:
        matches = re.findall(pattern, content)
        strings.extend(matches)
    
    return strings

def decode_base64_strings(strings):
    """Attempt to decode base64 encoded strings"""
    decoded = []
    for s in strings:
        try:
            # Try different padding
            for padding in ['', '=', '==', '===']:
                try:
                    decoded_bytes = base64.b64decode(s + padding)
                    decoded_str = decoded_bytes.decode('utf-8', errors='ignore')
                    if len(decoded_str) > 10:  # Only keep substantial strings
                        decoded.append(decoded_str)
                        break
                except:
                    continue
        except:
            continue
    return decoded

def analyze_obfuscation_structure(content):
    """Analyze the structure of the obfuscated code"""
    print("=== MoonSec V3 Analysis ===")
    
    # Extract the main obfuscation pattern
    moonsec_pattern = r'\(\[\[This file was protected with MoonSec V3\]\]\)'
    if re.search(moonsec_pattern, content):
        print("✓ MoonSec V3 protection detected")
    
    # Look for encoded string patterns
    encoded_strings = extract_encoded_strings(content)
    print(f"Found {len(encoded_strings)} potential encoded strings")
    
    # Try to decode strings
    decoded_strings = decode_base64_strings(encoded_strings)
    print(f"Successfully decoded {len(decoded_strings)} strings")
    
    # Look for function patterns
    function_patterns = [
        r'function\s+(\w+)',
        r'local\s+function\s+(\w+)',
        r'(\w+)\s*=\s*function',
    ]
    
    functions = []
    for pattern in function_patterns:
        matches = re.findall(pattern, content)
        functions.extend(matches)
    
    print(f"Found {len(functions)} function definitions")
    
    return {
        'encoded_strings': encoded_strings,
        'decoded_strings': decoded_strings,
        'functions': functions
    }

def extract_bytecode_patterns(content):
    """Extract and analyze bytecode patterns"""
    # Look for bytecode-like patterns
    bytecode_patterns = [
        r'local\s+(\w+)\s*=\s*0x[0-9a-fA-F]+',
        r'(\w+)\s*=\s*0x[0-9a-fA-F]+',
        r'while\s+\w+\s*<\s*0x[0-9a-fA-F]+',
    ]
    
    patterns = []
    for pattern in bytecode_patterns:
        matches = re.findall(pattern, content)
        patterns.extend(matches)
    
    return patterns

def attempt_simple_decryption(content):
    """Attempt simple decryption methods"""
    print("\n=== Attempting Decryption ===")
    
    # Try to find the main execution pattern
    main_pattern = r'return\s+function\([^)]*\)\s*local\s+([^;]+);'
    main_match = re.search(main_pattern, content, re.DOTALL)
    
    if main_match:
        print("✓ Found main execution pattern")
        main_code = main_match.group(0)
        print(f"Main code length: {len(main_code)}")
    
    # Look for string decoding functions
    decode_patterns = [
        r'(\w+)\s*=\s*function\([^)]*\)\s*local\s+[^;]+;',
        r'function\s+(\w+)\([^)]*\)\s*local\s+[^;]+;',
    ]
    
    decode_functions = []
    for pattern in decode_patterns:
        matches = re.findall(pattern, content, re.DOTALL)
        decode_functions.extend(matches)
    
    print(f"Found {len(decode_functions)} potential decode functions")
    
    return main_code if main_match else None

def main():
    # Read the obfuscated file
    with open('/workspace/invisible', 'r') as f:
        content = f.read()
    
    print(f"File size: {len(content)} characters")
    
    # Analyze the obfuscation
    analysis = analyze_obfuscation_structure(content)
    
    # Extract bytecode patterns
    bytecode = extract_bytecode_patterns(content)
    print(f"Found {len(bytecode)} bytecode patterns")
    
    # Attempt decryption
    main_code = attempt_simple_decryption(content)
    
    # Print some decoded strings for analysis
    if analysis['decoded_strings']:
        print("\n=== Sample Decoded Strings ===")
        for i, s in enumerate(analysis['decoded_strings'][:5]):
            print(f"{i+1}: {s[:100]}...")
    
    # Look for specific patterns that might indicate the original script
    script_indicators = [
        'game',
        'workspace',
        'players',
        'localplayer',
        'character',
        'humanoid',
        'torso',
        'head',
        'invisible',
        'transparency',
        'canCollide',
    ]
    
    found_indicators = []
    for indicator in script_indicators:
        if indicator.lower() in content.lower():
            found_indicators.append(indicator)
    
    print(f"\n=== Script Indicators Found ===")
    print(f"Found indicators: {found_indicators}")
    
    # Try to extract the core functionality
    print("\n=== Core Functionality Analysis ===")
    
    # Look for common Roblox script patterns
    roblox_patterns = [
        r'game\.(GetService|Players|Workspace)',
        r'local\s+(\w+)\s*=\s*game\.',
        r'(\w+)\.(Character|Humanoid|Torso|Head)',
    ]
    
    roblox_matches = []
    for pattern in roblox_patterns:
        matches = re.findall(pattern, content, re.IGNORECASE)
        roblox_matches.extend(matches)
    
    if roblox_matches:
        print("✓ Roblox-specific patterns detected")
        print(f"Found {len(roblox_matches)} Roblox patterns")
    else:
        print("⚠ No obvious Roblox patterns found in obfuscated code")

if __name__ == "__main__":
    main()