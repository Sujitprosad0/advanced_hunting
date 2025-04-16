# advanced_hunting
Automated Web Vulnerability Discovery Script
Automated Web Vulnerability Discovery Script
Description:
This script automates the process of discovering potential vulnerabilities across a target website or multiple URLs. Using various well-known tools, it performs a comprehensive analysis of the target and identifies different types of security flaws, including but not limited to XSS, SQL Injection, RCE, and sensitive data exposure.

The script performs the following steps:

Data Collection:

Collects endpoint parameters using ParamSpider.

Identifies JavaScript links using LinkFinder.

Crawls URLs using Katana.

Retrieves archived URLs using Waybackurls.

Performs brute-forcing of parameters using Arjun.

Gathers additional URLs from GauPlus.

URL Cleaning and Status Check:

Consolidates all discovered URLs into a single file.

Checks each URL’s HTTP status code using HTTPX and categorizes them into 200, 300, 403, and 404 responses.

Vulnerability Detection:

Runs GF patterns to search for common vulnerabilities such as XSS, SQLi, LFI, SSRF, and RCE.

Searches for secrets (API keys, credentials, etc.) using SecretFinder.

Runs Nuclei templates to detect CVEs, misconfigurations, exposure of sensitive data, and more.

Output:

Organizes and saves results into different directories based on the tool used and the type of vulnerability found.

Cleans up intermediate files to keep only the essential output.

Features:
Multi-tool Integration: Combines ParamSpider, LinkFinder, Katana, Waybackurls, Arjun, GauPlus, GF, SecretFinder, and Nuclei for thorough security testing.

Status Code Filtering: Automatically categorizes URLs based on their HTTP status codes (200, 300, 403, 404) to prioritize testing.

GF Patterns for Vulnerabilities: Runs well-known GF patterns to detect common web vulnerabilities.

Secret Detection: Finds potentially sensitive data like API keys and credentials exposed on the target website.

Nuclei CVE Templates: Detects common vulnerabilities and exposures using predefined Nuclei CVE templates.

Requirements:
ParamSpider: https://github.com/devanshbatham/ParamSpider

LinkFinder: https://github.com/GerbenJavado/LinkFinder

Katana: https://github.com/infosec-au/katana

Waybackurls: https://github.com/tomnomnom/waybackurls

Arjun: https://github.com/s0md3v/Arjun

GauPlus: https://github.com/lc/subfinder

GF: https://github.com/1ndianl33t/GF

SecretFinder: https://github.com/m4ll0k/SecretFinder

Nuclei: https://github.com/projectdiscovery/nuclei

Usage:
Clone the repository:

git clone https://github.com/your-repo-name/web-vuln-discovery.git
cd web-vuln-discovery
Make the script executable:

chmod +x vuln_discovery.sh
Run the script with a target URL or file containing multiple URLs:

./vuln_discovery.sh <target_url_or_file>
Output:
All output files are stored in the output/ directory.

The output includes:

httpx_output.txt: HTTP status codes check results.

200_urls_cleaned.txt: Cleaned URLs with 200 status codes.

gf_patterns_unique.txt: Results from GF vulnerability patterns.

secrets_200.txt: Potential secrets found on 200 status code URLs.

nuclei_*.txt: Nuclei vulnerability scan results for CVEs, misconfigurations, and exposure.

Contribution:
Feel free to contribute by opening issues or creating pull requests. If you have any suggestions for improvement, feel free to submit them.
